import 'package:flutter/material.dart';

import '../theme/watchdog_theme.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? helper;
  final IconData icon;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final wd = context.wd;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.secondaryContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: wd.border),
              ),
              child: Icon(icon, color: cs.onSecondaryContainer, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(value, style: Theme.of(context).textTheme.titleMedium),
                  if (helper != null) ...[
                    const SizedBox(height: 2),
                    Text(helper!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: wd.muted)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
