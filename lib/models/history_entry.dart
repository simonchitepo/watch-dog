import 'analysis_result.dart';

class HistoryEntry {
  final DateTime at;
  final String fileName;
  final int byteSize;
  final String sha256;

  final String? baselineSha256;
  final DateTime? baselineRegisteredAt;
  final bool? modifiedSinceBaseline;

  final double aiLikelihood;
  final double safetyScore;

  final String? note;

  const HistoryEntry({
    required this.at,
    required this.fileName,
    required this.byteSize,
    required this.sha256,
    required this.aiLikelihood,
    required this.safetyScore,
    this.baselineSha256,
    this.baselineRegisteredAt,
    this.modifiedSinceBaseline,
    this.note,
  });

  factory HistoryEntry.fromResult(AnalysisResult r, {String? note}) {
    return HistoryEntry(
      at: r.analyzedAt,
      fileName: r.fileName,
      byteSize: r.byteSize,
      sha256: r.sha256,
      baselineSha256: r.baselineSha256,
      baselineRegisteredAt: r.baselineRegisteredAt,
      modifiedSinceBaseline: r.modifiedSinceBaseline,
      aiLikelihood: r.aiLikelihood,
      safetyScore: r.safetyScore,
      note: note,
    );
  }

  Map<String, dynamic> toJson() => {
        'at': at.toIso8601String(),
        'fileName': fileName,
        'byteSize': byteSize,
        'sha256': sha256,
        'baselineSha256': baselineSha256,
        'baselineRegisteredAt': baselineRegisteredAt?.toIso8601String(),
        'modifiedSinceBaseline': modifiedSinceBaseline,
        'aiLikelihood': aiLikelihood,
        'safetyScore': safetyScore,
        'note': note,
      };

  static HistoryEntry fromJson(Map<String, dynamic> j) {
    return HistoryEntry(
      at: DateTime.parse(j['at'] as String),
      fileName: j['fileName'] as String,
      byteSize: j['byteSize'] as int,
      sha256: j['sha256'] as String,
      baselineSha256: j['baselineSha256'] as String?,
      baselineRegisteredAt: j['baselineRegisteredAt'] == null
          ? null
          : DateTime.parse(j['baselineRegisteredAt'] as String),
      modifiedSinceBaseline: j['modifiedSinceBaseline'] as bool?,
      aiLikelihood: (j['aiLikelihood'] as num).toDouble(),
      safetyScore: (j['safetyScore'] as num).toDouble(),
      note: j['note'] as String?,
    );
  }
}
