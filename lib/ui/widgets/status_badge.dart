import 'package:flutter/material.dart';
import '../theme/watchdog_theme.dart';

enum StatusKind { neutral, good, warn, bad }

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusKind kind;

  const StatusBadge({super.key, required this.label, required this.kind});

  @override
  Widget build(BuildContext context) {
    final t = context.wd;
    Color bg;
    Color fg;
    Color br;

    switch (kind) {
      case StatusKind.good:
        bg = t.good.withOpacity(0.12);
        fg = t.good;
        br = t.good.withOpacity(0.35);
        break;
      case StatusKind.warn:
        bg = t.warn.withOpacity(0.12);
        fg = t.warn;
        br = t.warn.withOpacity(0.35);
        break;
      case StatusKind.bad:
        bg = t.bad.withOpacity(0.12);
        fg = t.bad;
        br = t.bad.withOpacity(0.35);
        break;
      case StatusKind.neutral:
        bg = t.border.withOpacity(0.30);
        fg = Theme.of(context).colorScheme.onSurface;
        br = t.border;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: br),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg),
      ),
    );
  }
}
