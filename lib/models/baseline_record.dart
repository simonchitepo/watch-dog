class BaselineRecord {
  final String sha256;
  final DateTime registeredAt;

  const BaselineRecord({
    required this.sha256,
    required this.registeredAt,
  });

  Map<String, dynamic> toJson() => {
        'sha256': sha256,
        'registeredAt': registeredAt.toIso8601String(),
      };

  static BaselineRecord fromJson(Map<String, dynamic> j) {
    return BaselineRecord(
      sha256: j['sha256'] as String,
      registeredAt: DateTime.parse(j['registeredAt'] as String),
    );
  }
}
