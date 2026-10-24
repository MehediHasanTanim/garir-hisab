import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/l10n_labels.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/empty_state.dart';
import 'package:vehicle_khata/app/ui/widgets/khata_list_tile.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/money/number_formatter.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/reports/data/report_service.dart';
import 'package:vehicle_khata/features/reports/domain/profit_engine.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

enum _Period { today, week, month }

/// The Reports tab: profit summary, charts and a ranking of vehicles.
class ReportsPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  _Period _period = _Period.month;

  DayRange _range(CalendarDay today) => switch (_period) {
    _Period.today => DayRange(today, today),
    // Bangladesh's week starts on Saturday.
    _Period.week => DayRange(today.addDays(-((today.weekday - 6) % 7)), today),
    _Period.month => DayRange.month(today.year, today.month),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final f = ref.watch(numberFormatterProvider);
    final settings = ref.watch(settingsProvider);
    final today = ref.watch(todayProvider);
    final range = _range(today);
    final dashboard = ref.watch(
      dashboardProvider((
        startDay: range.start.epochDay,
        endDay: range.end.epochDay,
        vehicleId: null,
        accrual: settings.profitView.name == 'accrual',
        amortize: settings.amortizeFixed,
      )),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navReports)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Spacing.xl),
        children: [
          Padding(
            padding: const EdgeInsets.all(Spacing.gutter),
            child: SegmentedButton<_Period>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: _Period.today, label: Text(l10n.today)),
                ButtonSegment(
                  value: _Period.week,
                  label: Text(l10n.periodWeek),
                ),
                ButtonSegment(
                  value: _Period.month,
                  label: Text(l10n.filterThisMonth),
                ),
              ],
              selected: {_period},
              onSelectionChanged: (s) => setState(() => _period = s.first),
            ),
          ),
          dashboard.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(Spacing.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => Padding(
              padding: const EdgeInsets.all(Spacing.gutter),
              child: Text(l10n.errUnknown),
            ),
            data: (d) {
              if (d.days.isEmpty && d.expenseMix.isEmpty) {
                return SizedBox(
                  height: 320,
                  child: EmptyState(
                    icon: Icons.bar_chart_outlined,
                    title: l10n.reportsEmptyTitle,
                    message: l10n.noDataYet,
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SummaryCard(summary: d.summary, formatter: f),
                  if (range.length > 1) ...[
                    SectionHeader(l10n.trendTitle),
                    _TrendChart(dashboard: d, formatter: f),
                    SectionHeader(l10n.incomeVsCost),
                    _IncomeCostChart(dashboard: d, formatter: f),
                  ],
                  if (d.expenseMix.isNotEmpty) ...[
                    SectionHeader(l10n.expenseMixTitle),
                    _ExpenseMix(mix: d.expenseMix, formatter: f),
                  ],
                  if (d.byVehicle.isNotEmpty) ...[
                    SectionHeader(l10n.vehiclesRanking),
                    for (final v in d.byVehicle)
                      _VehicleRow(vehicle: v, formatter: f),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const new({required this.summary, required this.formatter});

  final ProfitSummary summary;
  final NumberFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    Widget row(String label, Money value, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: bold ? theme.textTheme.titleMedium : null,
            ),
          ),
          if (bold)
            AmountText(amount: value, formatter: formatter)
          else
            Text(formatter.money(value)),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.profitSummary,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              row(l10n.repIncome, summary.grossIncome),
              row(l10n.repRunning, -summary.variableCosts),
              row(l10n.repDriver, -summary.driverCost),
              row(l10n.repOperating, summary.operatingProfit),
              row(l10n.repVehicleCosts, -summary.fixedCosts),
              const Divider(),
              row(l10n.repNet, summary.netProfit, bold: true),
              if (summary.receivable.isPositive)
                Padding(
                  padding: const EdgeInsets.only(top: Spacing.sm),
                  child: Text(
                    '${l10n.repReceivable}: ${formatter.money(summary.receivable)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              if (summary.profitPerTrip != null)
                Text(
                  '${l10n.repPerTrip}: ${formatter.money(summary.profitPerTrip!)}',
                  style: theme.textTheme.bodySmall,
                ),
              if (summary.profitPerWorkingDay != null)
                Text(
                  '${l10n.repPerDay}: ${formatter.money(summary.profitPerWorkingDay!)}',
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One entry per calendar day of the period, zero where nothing happened.
List<({CalendarDay day, Money income, Money costs, Money net})> _series(
  Dashboard d,
) {
  final byDay = {for (final f in d.days) f.day.epochDay: f};
  return [
    for (final day in d.range.days)
      () {
        final fact = byDay[day.epochDay] ?? DayFacts(day: day);
        final s = summarize([fact], d.options);
        return (
          day: day,
          income: s.grossIncome,
          costs: s.variableCosts + s.driverCost + s.fixedCosts,
          net: s.netProfit,
        );
      }(),
  ];
}

class _TrendChart extends StatelessWidget {
  const new({required this.dashboard, required this.formatter});

  final Dashboard dashboard;
  final NumberFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final series = _series(dashboard);
    final spots = [
      for (var i = 0; i < series.length; i++)
        FlSpot(i.toDouble(), series[i].net.minor / 100),
    ];
    final label =
        '${l10n.trendTitle}: ${formatter.money(dashboard.summary.netProfit)}';

    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.gutter,
            Spacing.sm,
            Spacing.gutter,
            0,
          ),
          child: SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(),
                  rightTitles: AxisTitles(),
                  bottomTitles: AxisTitles(),
                  leftTitles: AxisTitles(),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    color: scheme.primary,
                    barWidth: 3,
                    dotData: FlDotData(show: spots.length <= 8),
                    belowBarData: BarAreaData(
                      show: true,
                      color: scheme.primary.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IncomeCostChart extends StatelessWidget {
  const new({required this.dashboard, required this.formatter});

  final Dashboard dashboard;
  final NumberFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final series = _series(dashboard);
    final rodWidth = series.length > 14 ? 3.0 : 8.0;
    final label =
        '${l10n.incomeVsCost}: ${formatter.money(dashboard.summary.grossIncome)}';

    return Semantics(
      label: label,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.gutter,
          Spacing.sm,
          Spacing.gutter,
          0,
        ),
        child: Column(
          children: [
            ExcludeSemantics(
              child: SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    gridData: const FlGridData(drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                    titlesData: const FlTitlesData(
                      topTitles: AxisTitles(),
                      rightTitles: AxisTitles(),
                      bottomTitles: AxisTitles(),
                      leftTitles: AxisTitles(),
                    ),
                    barGroups: [
                      for (var i = 0; i < series.length; i++)
                        BarChartGroupData(
                          x: i,
                          barsSpace: 1,
                          barRods: [
                            BarChartRodData(
                              toY: series[i].income.minor / 100,
                              width: rodWidth,
                              color: scheme.primary,
                            ),
                            BarChartRodData(
                              toY: series[i].costs.minor / 100,
                              width: rodWidth,
                              color: scheme.tertiary,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Wrap(
              spacing: Spacing.md,
              children: [
                _LegendDot(color: scheme.primary, label: l10n.chartIncome),
                _LegendDot(color: scheme.tertiary, label: l10n.chartCosts),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const new({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: Spacing.xs),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _ExpenseMix extends ConsumerWidget {
  const new({required this.mix, required this.formatter});

  final List<CategoryTotal> mix;
  final NumberFormatter formatter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final categories = ref.watch(allCategoriesProvider).value ?? const [];
    final palette = [
      scheme.primary,
      scheme.tertiary,
      scheme.secondary,
      scheme.error,
      scheme.inversePrimary,
      scheme.outline,
    ];

    // The biggest five categories, and everything else as one slice.
    final top = mix.take(5).toList();
    final rest = mix.skip(5).fold<Money>(Money.zero, (a, c) => a + c.amount);
    final total = mix.fold<Money>(Money.zero, (a, c) => a + c.amount);

    String nameOf(String id) {
      final c = categories.where((c) => c.id == id).firstOrNull;
      return c == null ? '' : l10n.categoryLabel(c);
    }

    final slices = [
      for (var i = 0; i < top.length; i++)
        (
          name: nameOf(top[i].categoryId),
          amount: top[i].amount,
          color: palette[i],
        ),
      if (rest.isPositive)
        (name: l10n.catOther, amount: rest, color: palette[5]),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
      child: Column(
        children: [
          ExcludeSemantics(
            child: SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 48,
                  sectionsSpace: 2,
                  sections: [
                    for (final s in slices)
                      PieChartSectionData(
                        value: s.amount.minor / 100,
                        color: s.color,
                        radius: 32,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
            ),
          ),
          // The legend carries the exact figures, so the chart is not the
          // only way to read them.
          for (final s in slices)
            ListTile(
              dense: true,
              minTileHeight: 40,
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: s.color,
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(s.name),
              trailing: Text(
                '${formatter.money(s.amount)} · ${formatter.digits((s.amount.minor * 100 ~/ (total.minor == 0 ? 1 : total.minor)).toString())}%',
              ),
            ),
        ],
      ),
    );
  }
}

class _VehicleRow extends StatelessWidget {
  const new({required this.vehicle, required this.formatter});

  final VehicleProfit vehicle;
  final NumberFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return KhataListTile(
      icon: Icons.directions_car_outlined,
      title: vehicle.nickname,
      subtitle:
          '${l10n.repIncome}: ${formatter.money(vehicle.summary.grossIncome)}',
      amount: vehicle.summary.netProfit,
      formatter: formatter,
    );
  }
}
