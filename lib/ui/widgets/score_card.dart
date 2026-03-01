import 'package:flutter/material.dart';

import '../theme/watchdog_theme.dart';
import 'score_gauge.dart';
import 'status_badge.dart';

class ScoreCard extends StatelessWidget {
  final double aiLikelihood;
  final double safetyScore;
  final StatusKind safetyKind;
  final String safetyLabel;

  const ScoreCard({
    super.key,
    required this.aiLikelihood,
    required this.safetyScore,
    required this.safetyKind,
    required this.safetyLabel,
  });

  @override
  Widget build(BuildContext context) {
    final wd = context.wd;

    Color safetyColor;
    switch (safetyKind) {
      case StatusKind.good:
        safetyColor = wd.good;
        break;
      case StatusKind.warn:
        safetyColor = wd.warn;
        break;
      case StatusKind.bad:
        safetyColor = wd.bad;
        break;
      case StatusKind.neutral:
        safetyColor = Theme.of(context).colorScheme.primary;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth > 560;
            final children = [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overview', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StatusBadge(label: safetyLabel, kind: safetyKind),
                      StatusBadge(
                        label: 'AI-likeness ${(aiLikelihood * 100).round()}%',
                        kind: aiLikelihood >= 0.72 ? StatusKind.warn : StatusKind.neutral,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Safety score is a best-effort heuristic. Always verify high-risk files using trusted tools.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: wd.muted),
                  ),
                ],
              ),
              const SizedBox(width: 12, height: 12),
              Wrap(
                spacing: 18,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ScoreGauge(
                    score: safetyScore,
                    label: 'Safety',
                    color: safetyColor,
                  ),
                  ScoreGauge(
                    score: aiLikelihood,
                    label: 'AI-likeness',
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ];

            return wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: children[0]),
                      children[1],
                      children[2],
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  );
          },
        ),
      ),
    );
  }
}
