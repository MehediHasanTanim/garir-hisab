import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/format.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/big_button.dart';
import 'package:vehicle_khata/app/ui/widgets/empty_state.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// End-of-day view: what came in, what went out, the net, and what is due to
/// the driver.
class CloseDayPage extends ConsumerWidget {
  const new({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final f = ref.watch(numberFormatterProvider);
    final settings = ref.watch(settingsProvider);
    final today = ref.watch(todayProvider);
    final vehicle = ref.watch(vehicleProvider(vehicleId)).value;
    final assignment = ref.watch(activeAssignmentProvider(vehicleId)).value;
    final dashboard = ref.watch(
      dashboardProvider((
        startDay: today.epochDay,
        endDay: today.epochDay,
        vehicleId: vehicleId,
        accrual: settings.profitView.name == 'accrual',
        amortize: settings.amortizeFixed,
      )),
    );

    if (vehicle == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(icon: Icons.search_off, title: l10n.vehicleNotFound),
      );
    }
    final s = dashboard.value?.summary;
    final title = '${l10n.closeDayTitle} · ${formatDay(f, today)}';

    Widget row(String label, String value, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: bold ? theme.textTheme.titleMedium : null,
            ),
          ),
          Text(
            value,
            style: bold
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  )
                : null,
          ),
        ],
      ),
    );

    String settlement() {
      if (assignment == null) return l10n.settlementNone;
      final name = assignment.driverName;
      return switch (assignment.assignment.payModel) {
        JamaPay(:final amount) => l10n.settlementJama(f.money(amount), name),
        SalaryPay() || MixedPay() => l10n.settlementSalary(name),
        DailyWagePay() => l10n.settlementDaily(name),
        PerTripPay() || CommissionPay() => l10n.settlementPerTrip(name),
      };
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(Spacing.gutter),
                children: [
                  Text(vehicle.nickname, style: theme.textTheme.titleLarge),
                  const SizedBox(height: Spacing.md),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.md),
                      child: s == null
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              children: [
                                row(
                                  l10n.closeDayIncome,
                                  f.money(s.grossIncome),
                                ),
                                row(
                                  l10n.closeDayRunning,
                                  f.money(-s.variableCosts),
                                ),
                                row(
                                  l10n.closeDayDriver,
                                  f.money(-s.driverCost),
                                ),
                                row(
                                  l10n.closeDayVehicleCosts,
                                  f.money(-s.fixedCosts),
                                ),
                                const Divider(),
                                row(
                                  l10n.closeDayNet,
                                  f.money(s.netProfit),
                                  bold: true,
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  Text(l10n.settlementTitle, style: theme.textTheme.titleSmall),
                  const SizedBox(height: Spacing.sm),
                  Text(settlement()),
                  if (assignment != null &&
                      assignment.assignment.payModel is! JamaPay)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        onPressed: () => context.push(
                          '/drivers/${assignment.assignment.driverId}',
                        ),
                        child: Text(assignment.driverName),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.gutter,
                Spacing.sm,
                Spacing.gutter,
                Spacing.md,
              ),
              child: BigButton(
                label: l10n.keypadDone,
                icon: Icons.check,
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
