import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/watchdog_theme.dart';

class HashField extends StatelessWidget {
  final String label;
  final String value;

  const HashField({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final wd = context.wd;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: wd.border.withOpacity(0.18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: wd.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: SelectableText(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Copy',
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: value));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  }
                },
                icon: const Icon(Icons.copy),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
