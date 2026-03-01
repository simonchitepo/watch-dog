import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../state/watchdog_controller.dart';
import '../theme/watchdog_theme.dart';
import '../widgets/layout.dart';
import '../widgets/section_card.dart';
import '../widgets/status_badge.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _query = '';
  HistoryFilter _filter = HistoryFilter.all;

  final Set<String> _expandedHash = <String>{};

  @override
  Widget build(BuildContext context) {
    final c = context.watch<WatchdogController>();
    final wd = context.wd;
    final fmt = DateFormat('yyyy-MM-dd  HH:mm');

    final q = _query.toLowerCase().trim();

    var items = c.history.where((h) {
      if (q.isEmpty) return true;
      final hayName = h.fileName.toLowerCase();
      final hayHash = h.sha256.toLowerCase();
      final hayDate = fmt.format(h.at).toLowerCase();
      return hayName.contains(q) || hayHash.contains(q) || hayDate.contains(q);
    }).toList();

    items = items.where((h) {
      switch (_filter) {
        case HistoryFilter.all:
          return true;
        case HistoryFilter.withBaseline:
          return h.baselineSha256 != null;
        case HistoryFilter.noBaseline:
          return h.baselineSha256 == null;
        case HistoryFilter.flagged:
          return _verdictKind(c, h) != VerdictKind.safe;
      }
    }).toList();

    final groups = _groupByAge(items);

    return ResponsiveGutter(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search by name, hash, or date…',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                tooltip: 'Clear all history',
                onPressed: c.history.isEmpty
                    ? null
                    : () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Clear all history?'),
                      content: const Text('This removes all stored scan history from this device.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear')),
                      ],
                    ),
                  );
                  if (ok == true) await c.clearHistory();
                },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filter == HistoryFilter.all,
                  onTap: () => setState(() => _filter = HistoryFilter.all),
                ),
                _FilterChip(
                  label: 'With baseline',
                  selected: _filter == HistoryFilter.withBaseline,
                  onTap: () => setState(() => _filter = HistoryFilter.withBaseline),
                ),
                _FilterChip(
                  label: 'No baseline',
                  selected: _filter == HistoryFilter.noBaseline,
                  onTap: () => setState(() => _filter = HistoryFilter.noBaseline),
                ),
                _FilterChip(
                  label: 'Flagged',
                  selected: _filter == HistoryFilter.flagged,
                  onTap: () => setState(() => _filter = HistoryFilter.flagged),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: _buildBody(
              context: context,
              controller: c,
              tokens: wd,
              groups: groups,
              fmt: fmt,
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'All scans performed locally. No files uploaded.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: wd.muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required WatchdogController controller,
    required WatchdogTokens tokens,
    required _GroupedHistory groups,
    required DateFormat fmt,
  }) {
    if (controller.history.isEmpty) {
      return SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No scans yet.', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(
              'Run your first scan to see results here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: tokens.muted),
            ),
          ],
        ),
      );
    }

    final hasAny = groups.today.isNotEmpty || groups.last7.isNotEmpty || groups.older.isNotEmpty;
    if (!hasAny) {
      return SectionCard(
        child: Text(
          'No results match your search / filters.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: tokens.muted),
        ),
      );
    }

    final sections = <_Section>[];
    if (groups.today.isNotEmpty) sections.add(_Section('Today', groups.today));
    if (groups.last7.isNotEmpty) sections.add(_Section('Last 7 days', groups.last7));
    if (groups.older.isNotEmpty) sections.add(_Section('Older', groups.older));

    return ListView.separated(
      itemCount: sections.fold<int>(0, (sum, s) => sum + 1 + s.items.length),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        int cursor = 0;

        for (final section in sections) {
          if (index == cursor) {
            return Padding(
              padding: const EdgeInsets.only(left: 4, top: 2),
              child: Text(
                section.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: tokens.muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }
          cursor += 1;

          final localIndex = index - cursor;
          if (localIndex >= 0 && localIndex < section.items.length) {
            final h = section.items[localIndex];

            final verdict = _verdict(controller, h);
            final integrityKind = (h.modifiedSinceBaseline == true)
                ? StatusKind.bad
                : (h.baselineSha256 == null ? StatusKind.neutral : StatusKind.good);

            final integrityLabel = h.baselineSha256 == null
                ? 'Baseline not set'
                : (h.modifiedSinceBaseline == true ? 'Integrity changed' : 'Integrity ok');

            final safetyText = _safetyLabel(controller, h.safetyScore);
            final safetyKind = h.safetyScore >= 0.72
                ? StatusKind.good
                : (h.safetyScore >= controller.settings.safetyWarnThreshold ? StatusKind.warn : StatusKind.bad);

            final aiText = _aiSignalsLabel(controller, h.aiLikelihood);
            final aiKind =
            h.aiLikelihood >= controller.settings.aiWarnThreshold ? StatusKind.warn : StatusKind.neutral;

            final key = '${h.at.millisecondsSinceEpoch}:${h.sha256}';
            final isExpanded = _expandedHash.contains(key);

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedHash.remove(key);
                  } else {
                    _expandedHash.add(key);
                  }
                });
              },
              child: SectionCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            h.fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 10),
                        StatusBadge(label: verdict.label, kind: verdict.kind),
                        const SizedBox(width: 6),
                        Icon(Icons.chevron_right, color: tokens.muted),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        StatusBadge(label: 'Safety: $safetyText', kind: safetyKind),
                        StatusBadge(label: 'AI signals: $aiText', kind: aiKind),
                        StatusBadge(label: integrityLabel, kind: integrityKind),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text(
                      isExpanded ? 'SHA-256: ${h.sha256}' : 'SHA-256 • ${_truncateHash(h.sha256)}',
                      maxLines: isExpanded ? 3 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: tokens.muted,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      '${fmt.format(h.at)} • ${_humanSize(h.byteSize)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: tokens.muted),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Details: Safety ${(h.safetyScore * 100).round()}% • AI ${(h.aiLikelihood * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: tokens.muted),
                    ),
                  ],
                ),
              ),
            );
          }

          cursor += section.items.length;
        }

        return const SizedBox.shrink();
      },
    );
  }

  VerdictKind _verdictKind(WatchdogController c, dynamic h) {
    if (h.modifiedSinceBaseline == true) return VerdictKind.integrityChanged;
    if (h.safetyScore < c.settings.safetyWarnThreshold) return VerdictKind.risky;

    final needsReview =
        (h.safetyScore < 0.72) || (h.aiLikelihood >= c.settings.aiWarnThreshold) || (h.baselineSha256 == null);

    if (needsReview) return VerdictKind.review;
    return VerdictKind.safe;
  }

  _Verdict _verdict(WatchdogController c, dynamic h) {
    final kind = _verdictKind(c, h);
    switch (kind) {
      case VerdictKind.safe:
        return const _Verdict('Likely safe', StatusKind.good);
      case VerdictKind.review:
        return const _Verdict('Review recommended', StatusKind.warn);
      case VerdictKind.risky:
        return const _Verdict('Potentially risky', StatusKind.bad);
      case VerdictKind.integrityChanged:
        return const _Verdict('Integrity changed', StatusKind.bad);
    }
  }

  String _safetyLabel(WatchdogController c, double safetyScore) {
    if (safetyScore >= 0.72) return 'Good';
    if (safetyScore >= c.settings.safetyWarnThreshold) return 'Review';
    return 'Risky';
  }

  String _aiSignalsLabel(WatchdogController c, double aiLikelihood) {
    if (aiLikelihood >= c.settings.aiWarnThreshold) return 'High';
    if (aiLikelihood >= (c.settings.aiWarnThreshold * 0.6)) return 'Medium';
    return 'Low';
  }

  _GroupedHistory _groupByAge(List<dynamic> items) {
    final now = DateTime.now();
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    final today = <dynamic>[];
    final last7 = <dynamic>[];
    final older = <dynamic>[];

    for (final h in items) {
      final d = h.at as DateTime;
      if (sameDay(d, now)) {
        today.add(h);
      } else if (now.difference(d).inDays < 7) {
        last7.add(h);
      } else {
        older.add(h);
      }
    }

    int byDateDesc(dynamic a, dynamic b) => (b.at as DateTime).compareTo(a.at as DateTime);
    today.sort(byDateDesc);
    last7.sort(byDateDesc);
    older.sort(byDateDesc);

    return _GroupedHistory(today: today, last7: last7, older: older);
  }

  String _truncateHash(String sha256) {
    if (sha256.length <= 14) return sha256;
    final start = sha256.substring(0, 6);
    final end = sha256.substring(sha256.length - 4);
    return '$start…$end';
  }

  String _humanSize(int bytes) {
    const kb = 1024.0;
    const mb = kb * 1024.0;
    final b = bytes.toDouble();
    if (b >= mb) return '${(b / mb).toStringAsFixed(2)} MB';
    if (b >= kb) return '${(b / kb).toStringAsFixed(1)} KB';
    return '$bytes B';
  }
}

enum HistoryFilter { all, withBaseline, noBaseline, flagged }
enum VerdictKind { safe, review, risky, integrityChanged }

class _Verdict {
  const _Verdict(this.label, this.kind);
  final String label;
  final StatusKind kind;
}

class _GroupedHistory {
  const _GroupedHistory({required this.today, required this.last7, required this.older});
  final List<dynamic> today;
  final List<dynamic> last7;
  final List<dynamic> older;
}

class _Section {
  const _Section(this.title, this.items);
  final String title;
  final List<dynamic> items;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
