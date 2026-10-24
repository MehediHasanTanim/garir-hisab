import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_khata/app/l10n_labels.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/amount_sheet.dart';
import 'package:vehicle_khata/app/ui/widgets/big_button.dart';
import 'package:vehicle_khata/app/ui/widgets/khata_list_tile.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/features/app_lock/presentation/app_lock_controller.dart';
import 'package:vehicle_khata/features/daylog/data/day_log_repository.dart';
import 'package:vehicle_khata/features/expenses/data/expense_repository.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/expenses/presentation/expense_editor.dart';
import 'package:vehicle_khata/features/vehicles/data/vehicle_repository.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

const _quickAmounts = [50, 100, 200, 500];

/// Today's income and profit for one vehicle, with one-tap ways to add the
/// day's takings and fuel.
class TodayCard extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final f = ref.watch(numberFormatterProvider);
    final settings = ref.watch(settingsProvider);
    final today = ref.watch(todayProvider);
    final vehicles =
        (ref
                    .watch(vehicleListProvider(const VehicleFilter(limit: 500)))
                    .value ??
                const [])
            .where((v) => v.isActive)
            .toList();
    if (vehicles.isEmpty) return const SizedBox.shrink();

    final selectedId = ref.watch(todayVehicleProvider);
    final vehicle =
        vehicles.where((v) => v.id == selectedId).firstOrNull ??
        // The list is newest first; default to the vehicle added first.
        vehicles.last;

    final summary = ref
        .watch(
          dashboardProvider((
            startDay: today.epochDay,
            endDay: today.epochDay,
            vehicleId: vehicle.id,
            accrual: settings.profitView.name == 'accrual',
            amortize: settings.amortizeFixed,
          )),
        )
        .value
        ?.summary;
    final income = summary?.grossIncome ?? Money.zero;
    final profit = summary?.netProfit ?? Money.zero;
    final title = l10n.todayWithVehicle(vehicle.nickname);

    Future<void> add(Money amount) =>
        _addIncome(context, ref, vehicle.id, amount);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.gutter,
        Spacing.sm,
        Spacing.gutter,
        Spacing.sm,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(title, style: theme.textTheme.titleMedium),
                  ),
                  if (vehicles.length > 1)
                    PopupMenuButton<String>(
                      tooltip: l10n.payVehicle,
                      icon: const Icon(Icons.swap_horiz),
                      onSelected: (id) =>
                          ref.read(todayVehicleProvider.notifier).select(id),
                      itemBuilder: (_) => [
                        for (final v in vehicles)
                          PopupMenuItem(value: v.id, child: Text(v.nickname)),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _Figure(
                      label: l10n.incomeToday,
                      child: Text(
                        f.money(income),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _Figure(
                      label: l10n.profitToday,
                      child: AmountText(
                        amount: profit,
                        formatter: f,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.sm,
                children: [
                  for (final amount in _quickAmounts)
                    ActionChip(
                      label: Text('+${f.money(Money.taka(amount))}'),
                      onPressed: () => add(Money.taka(amount)),
                    ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              BigButton(
                label: l10n.addIncome,
                icon: Icons.add,
                onPressed: () async {
                  final amount = await showAmountSheet(
                    context,
                    title: l10n.addIncome,
                  );
                  if (amount != null && amount.isPositive) await add(amount);
                },
              ),
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: Spacing.sm,
                children: [
                  TextButton.icon(
                    onPressed: () => _addGas(context, ref, vehicle.id),
                    icon: const Icon(Icons.local_gas_station_outlined),
                    label: Text(l10n.gasFuel),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        context.push('/vehicles/${vehicle.id}/close-day'),
                    icon: const Icon(Icons.fact_check_outlined),
                    label: Text(l10n.closeDay),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addIncome(
    BuildContext context,
    WidgetRef ref,
    String vehicleId,
    Money amount,
  ) async {
    final l10n = AppLocalizations.of(context);
    final f = ref.read(numberFormatterProvider);
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(dayLogRepositoryProvider);
    final today = ref.read(todayProvider);

    await repo.addIncome(vehicleId: vehicleId, day: today, amount: amount);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.incomeAdded(f.money(amount))),
          // An action keeps a snackbar up until dismissed; the undo window
          // should end by itself instead of covering buttons.
          persist: false,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () async {
              try {
                await repo.addIncome(
                  vehicleId: vehicleId,
                  day: today,
                  amount: -amount,
                );
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(l10n.incomeUndone)));
              } on DayLogException {
                // Already reduced elsewhere; nothing left to undo.
              }
            },
          ),
        ),
      );
  }

  Future<void> _addGas(
    BuildContext context,
    WidgetRef ref,
    String vehicleId,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(expenseRepositoryProvider);
    // The same editor as any other fuel expense: amount, quantity, odometer.
    final result = await showExpenseEditor(
      context,
      initial: ExpenseDraft(
        categoryId: ExpenseCategory.defaultId(DefaultCategory.fuel),
        amount: Money.zero,
        spentAt: ref.read(clockProvider)().toUtc(),
      ),
      showDate: true,
    );
    final draft = result?.draft;
    if (draft == null) return;
    try {
      await repo.create(vehicleId, draft);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.expenseSaved)));
    } on ExpenseException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.expenseError(e.error))),
      );
    }
  }
}

class _Figure extends StatelessWidget {
  const new({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelMedium),
      child,
    ],
  );
}
