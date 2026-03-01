import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../models/analysis_result.dart';
import '../models/baseline_record.dart';
import '../models/settings.dart';

class FileAnalyzer {
  const FileAnalyzer();

  /// Returns (isText, decodedText?) best-effort.
  (bool, String?) _tryDecodeText(Uint8List bytes) {
    // Quick binary sniff: NUL byte often indicates binary.
    final sampleLen = bytes.length < 4096 ? bytes.length : 4096;
    for (var i = 0; i < sampleLen; i++) {
      if (bytes[i] == 0) return (false, null);
    }

    try {
      final s = utf8.decode(bytes, allowMalformed: true);
      // If it's mostly replacement chars, treat as binary.
      final repl = '�';
      final replCount = repl.allMatches(s).length;
      final ratio = s.isEmpty ? 0.0 : (replCount / s.length);
      if (ratio > 0.06) return (false, null);
      return (true, s);
    } catch (_) {
      return (false, null);
    }
  }

  String sha256Hex(Uint8List bytes) {
    final digest = sha256.convert(bytes);
    return digest.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  AnalysisResult analyze({
    required String fileId,
    required String fileName,
    required Uint8List bytes,
    required AppSettings settings,
    BaselineRecord? baseline,
  }) {
    final analyzedAt = DateTime.now();
    final hash = sha256Hex(bytes);

    final (isText, text) = _tryDecodeText(bytes);

    int? chars;
    int? words;
    int? lines;

    if (isText && text != null) {
      final trimmed = text.trim();
      chars = trimmed.length;
      words = trimmed.isEmpty ? 0 : trimmed.split(RegExp(r'\s+')).length;
      lines = trimmed.isEmpty ? 0 : '\n'.allMatches(trimmed).length + 1;
    }

    // Keyword hits
    final keywordHits = <String>[];
    if (isText && text != null) {
      final lower = text.toLowerCase();
      for (final kw in settings.aiKeywords) {
        final needle = kw.toLowerCase().trim();
        if (needle.isEmpty) continue;
        if (lower.contains(needle)) keywordHits.add(kw);
      }
    }

    // Heuristics:
    // - aiLikelihood increases with keyword hits and certain patterns.
    // - safetyScore decreases for suspicious patterns and when file is modified vs baseline.
    final hitScore = keywordHits.isEmpty
        ? 0.0
        : (keywordHits.length / (settings.aiKeywords.length.clamp(6, 20)));

    double patternScore = 0.0;
    if (isText && text != null) {
      final lower = text.toLowerCase();
      if (RegExp(r'\b(system|developer)\b').hasMatch(lower)) patternScore += 0.10;
      if (RegExp(r'\b(prompt|jailbreak|ignore previous)\b').hasMatch(lower)) patternScore += 0.18;
      if (RegExp(r'\b(api[_ -]?key|token|secret)\b').hasMatch(lower)) patternScore += 0.18;
      if (RegExp(r'\bcurl\b|\bhttp(s)?://').hasMatch(lower)) patternScore += 0.05;
    }

    final aiLikelihood = (0.10 + hitScore + patternScore).clamp(0.0, 1.0);

    final modifiedSinceBaseline = baseline == null ? null : (baseline.sha256 != hash);

    double safety = 0.85; // start optimistic
    if (!isText) safety -= 0.05; // unknown content
    safety -= (aiLikelihood * 0.25);
    if (modifiedSinceBaseline == true) safety -= 0.25;

    // Slightly penalize huge files (harder to inspect)
    final mb = bytes.length / (1024 * 1024);
    if (mb > 5) safety -= 0.05;
    if (mb > 25) safety -= 0.10;

    safety = safety.clamp(0.0, 1.0);

    final metrics = <String, double>{
      'size_kb': bytes.length / 1024.0,
      'ai_hits': keywordHits.length.toDouble(),
      'ai_likelihood': aiLikelihood,
      'safety_score': safety,
      if (chars != null) 'text_chars': chars.toDouble(),
      if (words != null) 'text_words': words.toDouble(),
      if (lines != null) 'text_lines': lines.toDouble(),
    };

    return AnalysisResult(
      fileId: fileId,
      fileName: fileName,
      byteSize: bytes.length,
      sha256: hash,
      baselineSha256: baseline?.sha256,
      baselineRegisteredAt: baseline?.registeredAt,
      modifiedSinceBaseline: modifiedSinceBaseline,
      isText: isText,
      textCharCount: chars,
      textWordCount: words,
      textLineCount: lines,
      aiLikelihood: aiLikelihood,
      safetyScore: safety,
      aiKeywordHits: keywordHits,
      metrics: metrics,
      analyzedAt: analyzedAt,
    );
  }
}
