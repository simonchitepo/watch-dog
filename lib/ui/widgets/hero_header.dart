import 'package:flutter/material.dart';

import '../theme/watchdog_theme.dart';
import 'status_badge.dart';

class HeroHeader extends StatelessWidget {
  final bool busy;
  final VoidCallback onPickFile;

  final String? fileName;
  final String? baselineLabel;
  final StatusKind baselineKind;

  final VoidCallback? onRegisterBaseline;
  final VoidCallback? onUpdateBaseline;
  final VoidCallback? onShare;

  const HeroHeader({
    super.key,
    required this.busy,
    required this.onPickFile,
    required this.fileName,
    required this.baselineLabel,
    required this.baselineKind,
    this.onRegisterBaseline,
    this.onUpdateBaseline,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final wd = context.wd;
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: wd.border),
              ),
              child: Icon(Icons.shield, color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName ?? 'No file selected',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      StatusBadge(
                        label: baselineLabel ?? 'Baseline: not set',
                        kind: baselineKind,
                      ),
                      if (onRegisterBaseline != null)
                        OutlinedButton.icon(
                          onPressed: busy ? null : onRegisterBaseline,
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          label: const Text('Set baseline'),
                        ),
                      if (onUpdateBaseline != null)
                        OutlinedButton.icon(
                          onPressed: busy ? null : onUpdateBaseline,
                          icon: const Icon(Icons.update, size: 18),
                          label: const Text('Update baseline'),
                        ),
                      if (onShare != null)
                        IconButton(
                          tooltip: 'Share report',
                          onPressed: busy ? null : onShare,
                          icon: const Icon(Icons.ios_share),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: busy ? null : onPickFile,
              icon: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file, size: 18),
              label: Text(busy ? 'Analyzing…' : 'Pick file'),
            ),
          ],
        ),
      ),
    );
  }
}
