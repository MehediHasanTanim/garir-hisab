import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/l10n_labels.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/format.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/empty_state.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/app_lock/presentation/app_lock_controller.dart';
import 'package:vehicle_khata/features/expenses/data/expense_repository.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/expenses/domain/fuel_efficiency.dart';
import 'package:vehicle_khata/features/expenses/presentation/expense_editor.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// Vehicle-level expenses (repairs, service, insurance…) and fuel efficiency.
class VehicleExpensesPage extends ConsumerWidget {
  const new({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final f = ref.watch(numberFormatterProvider);
    final vehicle = ref.watch(vehicleProvider(vehicleId)).value;
    final expenses = ref.watch(vehicleExpensesProvider(vehicleId));
    final categories = ref.watch(allCategoriesProvider).value ?? const [];

    if (vehicle == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(icon: Icons.search_off, title: l10n.vehicleNotFound),
      );
    }
    final title = '${l10n.vehicleExpenses} · ${vehicle.nickname}';

    String categoryOf(String id) {
      final c = categories.where((c) => c.id == id).firstOrNull;
      return c == null ? '' : l10n.categoryLabel(c);
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(
          context,
          ref,
          ExpenseDraft(
            categoryId: ExpenseCategory.defaultId(DefaultCategory.repair),
            amount: Money.zero,
            spentAt: ref.read(clockProvider)().toUtc(),
          ),
        ),
        icon: const Icon(Icons.add),
        label: Text(l10n.addExpense),
      ),
      body: expenses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.errUnknown)),
        data: (list) => ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            _FuelCard(vehicleId: vehicleId),
            if (list.isEmpty)
              SizedBox(
                height: 320,
                child: EmptyState(
                  icon: Icons.build_outlined,
                  title: l10n.vehicleExpensesEmptyTitle,
                  message: l10n.vehicleExpensesEmptyMessage,
                ),
              ),
            for (final e in list)
              ListTile(
                minTileHeight: 64,
                leading: const CircleAvatar(
                  child: Icon(Icons.receipt_long_outlined),
                ),
                title: Text(categoryOf(e.categoryId)),
                subtitle: Text(
                  [
                    formatDay(f, CalendarDay.fromDate(e.spentAt.toLocal())),
                    if (e.note != null) e.note!,
                  ].join(' · '),
                ),
                trailing: Text(
                  f.money(e.amount),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () => _edit(
                  context,
                  ref,
                  ExpenseDraft.fromExpense(e),
                  allowDelete: true,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    ExpenseDraft draft, {
    bool allowDelete = false,
  }) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(expenseRepositoryProvider);
    final store = ref.read(photoStoreProvider);

    final result = await showExpenseEditor(
      context,
      initial: draft,
      showDate: true,
      allowDelete: allowDelete,
    );
    if (result == null) return;

    try {
      if (result.delete) {
        await repo.delete(draft.id!);
        await store.delete(draft.receiptFile);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.expenseDeleted)));
        return;
      }
      final saved = result.draft!;
      if (draft.id == null) {
        await repo.create(vehicleId, saved);
      } else {
        await repo.update(draft.id!, saved);
        if (draft.receiptFile != null &&
            draft.receiptFile != saved.receiptFile) {
          await store.delete(draft.receiptFile);
        }
      }
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

final _fuelReportProvider = FutureProvider.autoDispose
    .family<FuelEfficiencyReport, String>((ref, vehicleId) async {
      // Refresh when expenses change.
      ref.watch(vehicleExpensesProvider(vehicleId));
      final fills = await ref
          .watch(expenseRepositoryProvider)
          .fuelFills(vehicleId);
      return fuelEfficiency(fills);
    });

class _FuelCard extends ConsumerWidget {
  const new({required this.vehicleId});

  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final f = ref.watch(numberFormatterProvider);
    final report = ref.watch(_fuelReportProvider(vehicleId)).value;
    if (report == null) return const SizedBox.shrink();

    final avg = report.averageKmPerUnit;
    return Padding(
      padding: const EdgeInsets.all(Spacing.gutter),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: const Icon(Icons.local_gas_station_outlined),
          title: Text(l10n.fuelEfficiency),
          subtitle: avg == null
              ? Text(l10n.fuelEffNeedMore)
              : Text(
                  '${l10n.fuelEffAverage(f.digits(avg.toStringAsFixed(1)))}\n'
                  '${l10n.fuelCostPerKm(f.money(report.averageCostPerKm!))}',
                ),
          isThreeLine: avg != null,
        ),
      ),
    );
  }
}
