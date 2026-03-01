import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/watchdog_controller.dart';
import '../theme/watchdog_theme.dart';
import '../widgets/layout.dart';
import '../widgets/section_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<WatchdogController>();
    final wd = context.wd;

    return ResponsiveGutter(
      child: ListView(
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.brightness_auto)),
                    ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode)),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode)),
                  ],
                  selected: {c.settings.themeMode},
                  onSelectionChanged: (s) => c.setThemeMode(s.first),
                ),
                const SizedBox(height: 10),
                Text(
                  'Primary accent uses red with a black/white base.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: wd.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Heuristics', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _SliderRow(
                  title: 'AI warning threshold',
                  value: c.settings.aiWarnThreshold,
                  left: 'lenient',
                  right: 'strict',
                  onChanged: (v) => c.updateThresholds(aiWarn: v),
                ),
                const SizedBox(height: 12),
                _SliderRow(
                  title: 'Safety warning threshold',
                  value: c.settings.safetyWarnThreshold,
                  left: 'strict',
                  right: 'lenient',
                  onChanged: (v) => c.updateThresholds(safetyWarn: v),
                ),
                const SizedBox(height: 10),
                Text(
                  'These only affect labels; scores are computed locally from simple patterns.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: wd.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Keywords', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Text(
                  'Used for AI/automation hints when scanning text files.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: wd.muted),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: c.settings.aiKeywords
                      .map((k) => Chip(
                    label: Text(k),
                    onDeleted: () => c.updateKeywords(
                      c.settings.aiKeywords.where((x) => x != k).toList(),
                    ),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final v = await showDialog<String>(
                      context: context,
                      builder: (ctx) => _AddKeywordDialog(),
                    );
                    if (v != null && v.trim().isNotEmpty) {
                      final next = [...c.settings.aiKeywords, v.trim()];
                      await c.updateKeywords(next);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add keyword'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Data', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Text(
                  'All data is stored locally on this device (SharedPreferences).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: wd.muted),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: c.history.isEmpty ? null : () => c.clearHistory(),
                      icon: const Icon(Icons.history),
                      label: const Text('Clear history'),
                    ),
                    FilledButton.icon(
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Wipe all data?'),
                            content: const Text('This removes history, baselines, and settings.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Wipe')),
                            ],
                          ),
                        );
                        if (ok == true) await c.wipeAllData();
                      },
                      icon: const Icon(Icons.delete_forever_outlined),
                      label: const Text('Wipe all'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String title;
  final double value;
  final String left;
  final String right;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.title,
    required this.value,
    required this.left,
    required this.right,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final wd = context.wd;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: Theme.of(context).textTheme.labelLarge)),
            Text('${(value * 100).round()}%', style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
        Slider(
          value: value.clamp(0.0, 1.0),
          onChanged: onChanged,
        ),
        Row(
          children: [
            Text(left, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: wd.muted)),
            const Spacer(),
            Text(right, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: wd.muted)),
          ],
        ),
      ],
    );
  }
}

class _AddKeywordDialog extends StatefulWidget {
  @override
  State<_AddKeywordDialog> createState() => _AddKeywordDialogState();
}

class _AddKeywordDialogState extends State<_AddKeywordDialog> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add keyword'),
      content: TextField(
        controller: _c,
        decoration: const InputDecoration(
          hintText: 'e.g. api key',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(context, _c.text),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
