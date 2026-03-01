import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../state/watchdog_controller.dart';
import '../theme/watchdog_theme.dart';
import '../widgets/disclaimer_banner.dart';
import '../widgets/hash_field.dart';
import '../widgets/hero_header.dart';
import '../widgets/layout.dart';
import '../widgets/metric_card.dart';
import '../widgets/metric_meter.dart';
import '../widgets/score_card.dart';
import '../widgets/section_card.dart';
import '../widgets/status_badge.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  StatusKind _baselineKind(bool? modified, bool hasBaseline) {
    if (!hasBaseline) return StatusKind.neutral;
    if (modified == true) return StatusKind.bad;
    if (modified == false) return StatusKind.good;
    return StatusKind.neutral;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WatchdogController>();
    final result = controller.latest;
    final wd = context.wd;

    final hasBaseline = result?.baselineSha256 != null;
    final baselineKind = _baselineKind(result?.modifiedSinceBaseline, hasBaseline);

    String baselineLabel;
    if (!hasBaseline) {
      baselineLabel = 'Baseline not set';
    } else {
      baselineLabel =
      (result?.modifiedSinceBaseline == true) ? 'Integrity changed' : 'Matches baseline';
    }

    StatusKind safetyKind = StatusKind.neutral;
    String safetyLabel = 'Safety: unknown';
    if (result != null) {
      if (result.safetyScore >= 0.72) {
        safetyKind = StatusKind.good;
        safetyLabel = 'Likely safe';
      } else if (result.safetyScore >= controller.settings.safetyWarnThreshold) {
        safetyKind = StatusKind.warn;
        safetyLabel = 'Review recommended';
      } else {
        safetyKind = StatusKind.bad;
        safetyLabel = 'Potentially risky';
      }
    }

    if (controller.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final msg = controller.error!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      });
    }

    return ResponsiveGutter(
      child: ListView(
        children: [
          HeroHeader(
            busy: controller.busy,
            onPickFile: controller.analyzePickedFile,
            fileName: result?.fileName,
            baselineLabel: baselineLabel,
            baselineKind: baselineKind,
            onRegisterBaseline: (result == null || controller.busy || hasBaseline)
                ? null
                : controller.registerBaselineForLatest,
            onUpdateBaseline: (result == null || controller.busy || !hasBaseline)
                ? null
                : controller.registerBaselineForLatest,
            onShare: (result == null || controller.busy)
                ? null
                : () async {
              await Share.share(
                controller.exportLatestAsJson(),
                subject: 'Watchdog report: ${result.fileName}',
              );
            },
          ),
          const SizedBox(height: 14),

          _LocalOnlyDisclosure(tokens: wd),
          const SizedBox(height: 10),

          const DisclaimerBanner(),
          const SizedBox(height: 14),

          if (result == null) ...[
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select a file to scan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Integrity + safety signals are computed locally and never uploaded.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: wd.muted),
                  ),
                  const SizedBox(height: 14),

                  // Red primary CTA via theme
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.busy ? null : controller.analyzePickedFile,
                      icon: controller.busy
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.upload_file_outlined),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          controller.busy ? 'Scanning…' : 'Pick file',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    ),
                  ),

                  const SizedBox(height: 14),
                  const _NextSteps(
                    busy: false,
                    stage1Done: false,
                    stage2Done: false,
                    stage3Done: false,
                  ),
                ],
              ),
            ),
          ] else ...[
            // ScoreCard will benefit from new theme colors automatically.
            ScoreCard(
              aiLikelihood: result.aiLikelihood,
              safetyScore: result.safetyScore,
              safetyKind: safetyKind,
              safetyLabel: safetyLabel,
            ),
            const SizedBox(height: 14),

            LayoutBuilder(builder: (context, cstr) {
              final wide = cstr.maxWidth > 760;

              final left = [
                HashField(label: 'SHA-256', value: result.sha256),
                if (hasBaseline) ...[
                  const SizedBox(height: 14),
                  HashField(label: 'Baseline SHA-256', value: result.baselineSha256!),
                ],
              ];

              final right = [
                MetricCard(
                  title: 'File size',
                  value: _humanSize(result.byteSize),
                  icon: Icons.sd_storage_outlined,
                ),
                MetricCard(
                  title: 'File type',
                  value: result.isText ? 'Text' : 'Binary',
                  helper: result.isText
                      ? '${result.textWordCount ?? 0} words • ${result.textLineCount ?? 0} lines'
                      : 'Heuristic: NUL-byte + decode test',
                  icon: result.isText ? Icons.description_outlined : Icons.memory_outlined,
                ),
                MetricCard(
                  title: 'Keyword hits',
                  value: '${result.aiKeywordHits.length}',
                  helper:
                  result.aiKeywordHits.isEmpty ? 'None' : result.aiKeywordHits.take(4).join(', '),
                  icon: Icons.manage_search_outlined,
                ),
              ];

              final meters = [
                MetricMeter(
                  title: 'Safety score',
                  value: result.safetyScore,
                  leftLabel: 'riskier',
                  rightLabel: 'safer',
                  tint: safetyKind == StatusKind.good
                      ? wd.good
                      : (safetyKind == StatusKind.bad ? wd.bad : wd.warn),
                ),
                MetricMeter(
                  title: 'AI-likeness',
                  value: result.aiLikelihood,
                  leftLabel: 'unlikely',
                  rightLabel: 'likely',
                ),
              ];

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          ...left,
                          const SizedBox(height: 14),
                          ...meters,
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          ...right.expand((w) => [w, const SizedBox(height: 12)]).toList()
                            ..removeLast(),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  ...left,
                  const SizedBox(height: 14),
                  ...right.expand((w) => [w, const SizedBox(height: 12)]).toList()..removeLast(),
                  const SizedBox(height: 14),
                  ...meters,
                ],
              );
            }),

            const SizedBox(height: 14),

            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What happens next', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  _NextSteps(
                    busy: controller.busy,
                    stage1Done: true,
                    stage2Done: hasBaseline,
                    stage3Done: true,
                  ),
                  if (!hasBaseline) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Tip: Save a baseline to detect future changes.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: wd.muted),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 14),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Details', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      StatusBadge(
                        label: hasBaseline
                            ? (result.modifiedSinceBaseline == true
                            ? 'Integrity: changed'
                            : 'Integrity: ok')
                            : 'Baseline: not set',
                        kind: baselineKind,
                      ),
                      if (result.aiKeywordHits.isNotEmpty)
                        StatusBadge(label: 'Keywords: ${result.aiKeywordHits.length}', kind: StatusKind.warn),
                      if (result.isText)
                        StatusBadge(label: 'Text stats available', kind: StatusKind.neutral),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Analysis time: ${result.analyzedAt}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: wd.muted),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _humanSize(int bytes) {
    const kb = 1024.0;
    const mb = kb * 1024.0;
    const gb = mb * 1024.0;
    final b = bytes.toDouble();
    if (b >= gb) return '${(b / gb).toStringAsFixed(2)} GB';
    if (b >= mb) return '${(b / mb).toStringAsFixed(2)} MB';
    if (b >= kb) return '${(b / kb).toStringAsFixed(1)} KB';
    return '$bytes B';
  }
}

class _LocalOnlyDisclosure extends StatelessWidget {
  const _LocalOnlyDisclosure({required this.tokens});
  final WatchdogTokens tokens;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'All analysis runs locally. No files are uploaded.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(top: 6),
              title: Text(
                'Learn more',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: tokens.muted),
              ),
              children: [
                Text(
                  'Results are computed on-device using hashing and simple heuristics. '
                      'This is not a guarantee of safety; use it as a triage signal.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: tokens.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextSteps extends StatelessWidget {
  const _NextSteps({
    required this.busy,
    required this.stage1Done,
    required this.stage2Done,
    required this.stage3Done,
  });

  final bool busy;
  final bool stage1Done;
  final bool stage2Done;
  final bool stage3Done;

  @override
  Widget build(BuildContext context) {
    final muted = context.wd.muted;

    return Column(
      children: [
        _StepRow(
          icon: stage1Done
              ? Icons.check_circle_outline
              : (busy ? Icons.hourglass_bottom : Icons.radio_button_unchecked),
          label: 'Hash computed',
          enabled: stage1Done || busy,
          mutedColor: muted,
        ),
        const SizedBox(height: 8),
        _StepRow(
          icon: stage2Done
              ? Icons.check_circle_outline
              : (busy ? Icons.hourglass_bottom : Icons.radio_button_unchecked),
          label: 'Baseline comparison',
          enabled: stage2Done || busy,
          mutedColor: muted,
        ),
        const SizedBox(height: 8),
        _StepRow(
          icon: stage3Done
              ? Icons.check_circle_outline
              : (busy ? Icons.hourglass_bottom : Icons.radio_button_unchecked),
          label: 'Heuristic checks',
          enabled: stage3Done || busy,
          mutedColor: muted,
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.mutedColor,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    final color = enabled ? null : mutedColor;

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: style?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
