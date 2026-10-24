import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/empty_state.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/jama/data/jama_repository.dart';
import 'package:vehicle_khata/features/jama/presentation/jama_page.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// More → Jama report: expected vs collected for a month, and who is behind.
class JamaReportPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<JamaReportPage> createState() => _JamaReportPageState();
}

class _JamaReportPageState extends ConsumerState<JamaReportPage> {
  late int _year;
  late int _month;
  Future<JamaReport>? _future;

  @override
  void initState() {
    super.initState();
    final t = ref.read(todayProvider);
    _year = t.year;
    _month = t.month;
    _load();
  }

  void _load() {
    _future = ref
        .read(jamaRepositoryProvider)
        .report(DayRange.month(_year, _month), ref.read(todayProvider));
  }

  void _shift(int by) {
    final d = CalendarDay.of(_year, _month + by, 1);
    setState(() {
      _year = d.year;
      _month = d.month;
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final f = ref.watch(numberFormatterProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.jamaReportTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: l10n.prevMonth,
                  onPressed: () => _shift(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    f.digits('$_year-${_month.toString().padLeft(2, '0')}'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: l10n.nextMonth,
                  onPressed: () => _shift(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<JamaReport>(
                future: _future,
                builder: (context, snap) {
                  final r = snap.data;
                  if (r == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (r.drivers.isEmpty) {
                    return EmptyState(
                      icon: Icons.event_note_outlined,
                      title: l10n.jamaNoData,
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.all(Spacing.gutter),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(Spacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _line(
                                l10n.jamaExpected,
                                f.money(r.expected),
                                theme,
                              ),
                              _line(
                                l10n.jamaCollectedLabel,
                                f.money(r.collected),
                                theme,
                              ),
                              _line(l10n.jamaBaki, f.money(r.due), theme),
                              const SizedBox(height: Spacing.sm),
                              Text(
                                l10n.jamaRate(f.digits('${r.ratePercent}')),
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: Spacing.xs),
                              LinearProgressIndicator(
                                value: r.ratePercent / 100,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: Spacing.lg),
                      Text(
                        l10n.jamaDefaulters,
                        style: theme.textTheme.titleMedium,
                      ),
                      if (r.defaulters.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: Spacing.sm),
                          child: Text(l10n.jamaNoDefaulters),
                        ),
                      for (final d in r.defaulters)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(d.driverName),
                          subtitle: Text(
                            l10n.jamaDefaulterLine(
                              f.digits('${d.missedDays}'),
                              jamaDate(f, d.oldestDue!),
                            ),
                          ),
                          trailing: Text(
                            f.money(d.due),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.expense,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(String label, String value, ThemeData theme) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    ),
  );
}
