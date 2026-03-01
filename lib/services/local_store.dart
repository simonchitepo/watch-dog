import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/baseline_record.dart';
import '../models/history_entry.dart';
import '../models/settings.dart';

class LocalStore {
  static const _kBaselines = 'baselines_v1';
  static const _kHistory = 'history_v1';
  static const _kSettings = 'settings_v1';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<Map<String, BaselineRecord>> loadBaselines() async {
    final p = await _prefs;
    final raw = p.getString(_kBaselines);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, BaselineRecord.fromJson((v as Map).cast<String, dynamic>())));
  }

  Future<void> saveBaselines(Map<String, BaselineRecord> map) async {
    final p = await _prefs;
    final encoded = jsonEncode(map.map((k, v) => MapEntry(k, v.toJson())));
    await p.setString(_kBaselines, encoded);
  }

  Future<List<HistoryEntry>> loadHistory() async {
    final p = await _prefs;
    final raw = p.getString(_kHistory);
    if (raw == null || raw.isEmpty) return [];
    final decoded = (jsonDecode(raw) as List).cast<Map>();
    return decoded
        .map((e) => HistoryEntry.fromJson(e.cast<String, dynamic>()))
        .toList()
      ..sort((a, b) => b.at.compareTo(a.at));
  }

  Future<void> saveHistory(List<HistoryEntry> history) async {
    final p = await _prefs;
    final encoded = jsonEncode(history.map((e) => e.toJson()).toList());
    await p.setString(_kHistory, encoded);
  }

  Future<AppSettings> loadSettings() async {
    final p = await _prefs;
    final raw = p.getString(_kSettings);
    if (raw == null || raw.isEmpty) return AppSettings.defaults();
    final decoded = (jsonDecode(raw) as Map).cast<String, dynamic>();
    return AppSettings.fromJson(decoded);
  }

  Future<void> saveSettings(AppSettings settings) async {
    final p = await _prefs;
    await p.setString(_kSettings, jsonEncode(settings.toJson()));
  }

  Future<void> clearAll() async {
    final p = await _prefs;
    await p.remove(_kBaselines);
    await p.remove(_kHistory);
    await p.remove(_kSettings);
  }
}
