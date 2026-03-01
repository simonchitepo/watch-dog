class AnalysisResult {
  final String fileId;
  final String fileName;
  final int byteSize;

  final String sha256;

  // Baseline metadata (local record)
  final String? baselineSha256;
  final DateTime? baselineRegisteredAt;

  // Derived
  final bool? modifiedSinceBaseline;

  // Content detection (best-effort heuristics)
  final bool isText;
  final int? textCharCount;
  final int? textWordCount;
  final int? textLineCount;

  // Heuristic scores (0..1)
  final double aiLikelihood;
  final double safetyScore;

  // Details
  final List<String> aiKeywordHits;
  final Map<String, double> metrics;

  final DateTime analyzedAt;

  const AnalysisResult({
    required this.fileId,
    required this.fileName,
    required this.byteSize,
    required this.sha256,
    required this.isText,
    required this.aiLikelihood,
    required this.safetyScore,
    required this.aiKeywordHits,
    required this.metrics,
    required this.analyzedAt,
    this.baselineSha256,
    this.baselineRegisteredAt,
    this.modifiedSinceBaseline,
    this.textCharCount,
    this.textWordCount,
    this.textLineCount,
  });

  Map<String, dynamic> toJson() => {
        'fileId': fileId,
        'fileName': fileName,
        'byteSize': byteSize,
        'sha256': sha256,
        'baselineSha256': baselineSha256,
        'baselineRegisteredAt': baselineRegisteredAt?.toIso8601String(),
        'modifiedSinceBaseline': modifiedSinceBaseline,
        'isText': isText,
        'textCharCount': textCharCount,
        'textWordCount': textWordCount,
        'textLineCount': textLineCount,
        'aiLikelihood': aiLikelihood,
        'safetyScore': safetyScore,
        'aiKeywordHits': aiKeywordHits,
        'metrics': metrics,
        'analyzedAt': analyzedAt.toIso8601String(),
      };

  static AnalysisResult fromJson(Map<String, dynamic> j) {
    return AnalysisResult(
      fileId: j['fileId'] as String,
      fileName: j['fileName'] as String,
      byteSize: j['byteSize'] as int,
      sha256: j['sha256'] as String,
      baselineSha256: j['baselineSha256'] as String?,
      baselineRegisteredAt: j['baselineRegisteredAt'] == null
          ? null
          : DateTime.parse(j['baselineRegisteredAt'] as String),
      modifiedSinceBaseline: j['modifiedSinceBaseline'] as bool?,
      isText: j['isText'] as bool,
      textCharCount: j['textCharCount'] as int?,
      textWordCount: j['textWordCount'] as int?,
      textLineCount: j['textLineCount'] as int?,
      aiLikelihood: (j['aiLikelihood'] as num).toDouble(),
      safetyScore: (j['safetyScore'] as num).toDouble(),
      aiKeywordHits: (j['aiKeywordHits'] as List).cast<String>(),
      metrics: (j['metrics'] as Map).map(
        (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
      ),
      analyzedAt: DateTime.parse(j['analyzedAt'] as String),
    );
  }
}
