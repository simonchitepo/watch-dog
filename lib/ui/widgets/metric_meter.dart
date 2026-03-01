import 'package:flutter/material.dart';

import '../theme/watchdog_theme.dart';

class MetricMeter extends StatelessWidget {
  final String title;
  final double value; // 0..1
  final String leftLabel;
  final String rightLabel;
  final Color? tint;

  const MetricMeter({
    super.key,
    required this.title,
    required this.value,
    required this.leftLabel,
    required this.rightLabel,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    final wd = context.wd;
    final cs = Theme.of(context).colorScheme;

    final barColor = tint ?? cs.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: Theme.of(context).textTheme.labelLarge)),
                Text('${(v * 100).round()}%', style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 10,
                backgroundColor: wd.border.withOpacity(0.25),
                color: barColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(leftLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: wd.muted)),
                const Spacer(),
                Text(rightLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: wd.muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
