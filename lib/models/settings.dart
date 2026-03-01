import 'package:flutter/material.dart';

class AppSettings {
  final ThemeMode themeMode;

  /// If aiLikelihood >= this -> "High AI-likeness" label
  final double aiWarnThreshold;

  /// If safetyScore <= this -> "Risky" label (score is 0..1, higher is safer)
  final double safetyWarnThreshold;

  /// Keywords used for basic AI/automation heuristics (case-insensitive).
  final List<String> aiKeywords;

  const AppSettings({
    required this.themeMode,
    required this.aiWarnThreshold,
    required this.safetyWarnThreshold,
    required this.aiKeywords,
  });

  factory AppSettings.defaults() => const AppSettings(
        themeMode: ThemeMode.system,
        aiWarnThreshold: 0.65,
        safetyWarnThreshold: 0.55,
        aiKeywords: [
          'openai',
          'chatgpt',
          'prompt',
          'gpt',
          'llm',
          'anthropic',
          'claude',
          'gemini',
          'system message',
          'jailbreak',
          'api key',
        ],
      );

  AppSettings copyWith({
    ThemeMode? themeMode,
    double? aiWarnThreshold,
    double? safetyWarnThreshold,
    List<String>? aiKeywords,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      aiWarnThreshold: aiWarnThreshold ?? this.aiWarnThreshold,
      safetyWarnThreshold: safetyWarnThreshold ?? this.safetyWarnThreshold,
      aiKeywords: aiKeywords ?? this.aiKeywords,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'aiWarnThreshold': aiWarnThreshold,
        'safetyWarnThreshold': safetyWarnThreshold,
        'aiKeywords': aiKeywords,
      };

  static AppSettings fromJson(Map<String, dynamic> j) {
    ThemeMode tm = ThemeMode.system;
    final name = (j['themeMode'] as String?) ?? 'system';
    tm = ThemeMode.values.firstWhere(
      (e) => e.name == name,
      orElse: () => ThemeMode.system,
    );

    return AppSettings(
      themeMode: tm,
      aiWarnThreshold: (j['aiWarnThreshold'] as num?)?.toDouble() ?? 0.65,
      safetyWarnThreshold: (j['safetyWarnThreshold'] as num?)?.toDouble() ?? 0.55,
      aiKeywords: (j['aiKeywords'] as List?)?.cast<String>() ??
          AppSettings.defaults().aiKeywords,
    );
  }
}
