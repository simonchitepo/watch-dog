import 'package:flutter/material.dart';
import '../theme/watchdog_theme.dart';

class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final wd = context.wd;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: wd.muted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'This app uses local heuristics (no cloud uploads). Results are not a substitute for professional security tooling.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: wd.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
