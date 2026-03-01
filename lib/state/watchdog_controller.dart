import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/analysis_result.dart';
import '../models/baseline_record.dart';
import '../models/history_entry.dart';
import '../models/settings.dart';
import '../services/file_analyzer.dart';
import '../services/local_store.dart';

class WatchdogController extends ChangeNotifier {
  final _store = LocalStore();
  final _analyzer = const FileAnalyzer();

  bool _ready = false;
  bool get ready => _ready;

  bool _busy = false;
  bool get busy => _busy;

  String? _error;
  String? get error => _error;

  AnalysisResult? _latest;
  AnalysisResult? get latest => _latest;

  AppSettings _settings = AppSettings.defaults();
  AppSettings get settings => _settings;

  final Map<String, BaselineRecord> _baselines = {};
  Map<String, BaselineRecord> get baselines => Map.unmodifiable(_baselines);

  final List<HistoryEntry> _history = [];
  List<HistoryEntry> get history => List.unmodifiable(_history);

  Future<void> init() async {
    _settings = await _store.loadSettings();
    _baselines
      ..clear()
      ..addAll(await _store.loadBaselines());
    _history
      ..clear()
      ..addAll(await _store.loadHistory());
    _ready = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await _store.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateThresholds({double? aiWarn, double? safetyWarn}) async {
    _settings = _settings.copyWith(
      aiWarnThreshold: aiWarn ?? _settings.aiWarnThreshold,
      safetyWarnThreshold: safetyWarn ?? _settings.safetyWarnThreshold,
    );
    await _store.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateKeywords(List<String> keywords) async {
    _settings = _settings.copyWith(aiKeywords: keywords);
    await _store.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> analyzePickedFile() async {
    _setBusy(true);
    _setError(null);

    try {
      final result = await FilePicker.platform.pickFiles(
        withData: true,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final f = result.files.first;
      final bytes = f.bytes;
      if (bytes == null) {
        throw StateError('Unable to read file bytes (permission denied or unsupported source).');
      }

      final fileId = (f.path?.isNotEmpty ?? false) ? f.path! : '${f.name}:${bytes.length}';
      final baseline = _baselines[fileId];

      final analysis = _analyzer.analyze(
        fileId: fileId,
        fileName: f.name,
        bytes: bytes,
        settings: _settings,
        baseline: baseline,
      );

      _latest = analysis;

      // Add to history (keep newest at top, cap at 250)
      _history.insert(0, HistoryEntry.fromResult(analysis));
      if (_history.length > 250) {
        _history.removeRange(250, _history.length);
      }
      await _store.saveHistory(_history);

      notifyListeners();
    } catch (e) {
      _setError(_safeError(e));
    } finally {
      _setBusy(false);
    }
  }

  Future<void> registerBaselineForLatest() async {
    final r = _latest;
    if (r == null) return;

    _setBusy(true);
    _setError(null);
    try {
      final baseline = BaselineRecord(sha256: r.sha256, registeredAt: DateTime.now());
      _baselines[r.fileId] = baseline;
      await _store.saveBaselines(_baselines);

      // Recompute derived fields (modifiedSinceBaseline etc.)
      _latest = AnalysisResult(
        fileId: r.fileId,
        fileName: r.fileName,
        byteSize: r.byteSize,
        sha256: r.sha256,
        baselineSha256: baseline.sha256,
        baselineRegisteredAt: baseline.registeredAt,
        modifiedSinceBaseline: false,
        isText: r.isText,
        textCharCount: r.textCharCount,
        textWordCount: r.textWordCount,
        textLineCount: r.textLineCount,
        aiLikelihood: r.aiLikelihood,
        safetyScore: r.safetyScore,
        aiKeywordHits: r.aiKeywordHits,
        metrics: r.metrics,
        analyzedAt: r.analyzedAt,
      );

      notifyListeners();
    } catch (e) {
      _setError(_safeError(e));
    } finally {
      _setBusy(false);
    }
  }

  Future<void> clearHistory() async {
    _history.clear();
    await _store.saveHistory(_history);
    notifyListeners();
  }

  Future<void> wipeAllData() async {
    _latest = null;
    _history.clear();
    _baselines.clear();
    _settings = AppSettings.defaults();
    await _store.clearAll();
    notifyListeners();
  }

  String exportLatestAsJson() {
    final r = _latest;
    if (r == null) return jsonEncode({'error': 'no_analysis'});
    return const JsonEncoder.withIndent('  ').convert(r.toJson());
  }

  void _setBusy(bool v) {
    _busy = v;
    notifyListeners();
  }

  void _setError(String? v) {
    _error = v;
    notifyListeners();
  }

  String _safeError(Object e) {
    final s = e.toString();
    if (s.length > 220) return s.substring(0, 220);
    return s;
  }
}
