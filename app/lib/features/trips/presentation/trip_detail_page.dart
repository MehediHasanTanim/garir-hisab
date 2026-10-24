import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_khata/app/l10n_labels.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/format.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/empty_state.dart';
import 'package:vehicle_khata/app/ui/widgets/khata_list_tile.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/money/money_parser.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/trips/data/trip_repository.dart';
import 'package:vehicle_khata/features/trips/domain/trip.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

class TripDetailPage extends ConsumerWidget {
  const new({required this.tripId, super.key});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(tripDetailProvider(tripId));

    return detail.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: EmptyState(icon: Icons.error_outline, title: l10n.errUnknown),
      ),
      data: (d) {
        if (d == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(icon: Icons.search_off, title: l10n.tripNotFound),
          );
        }
        return _Detail(detail: d);
      },
    );
  }
}

enum _Menu { repeat, returnLeg, delete }

class _Detail extends ConsumerWidget {
  const new({required this.detail});

  final TripDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final f = ref.watch(numberFormatterProvider);
    final t = detail.trip;
    final categories = ref.watch(allCategoriesProvider).value ?? const [];
    final vehicle = ref.watch(vehicleProvider(t.vehicleId)).value;
    final driver = t.driverId == null
        ? null
        : ref.watch(driverProvider(t.driverId!)).value;

    final ownerExpenses = detail.expenses
        .where((e) => e.isOwnerBorne)
        .map((e) => e.amount)
        .sum();
    final profit = t.fare - ownerExpenses - t.driverPay;
    final route = [t.fromPlace, t.toPlace].whereType<String>().join(' → ');
    final distanceText = t.distanceM == null
        ? ''
        : '${f.digits((t.distanceM! / 1000).toStringAsFixed(t.distanceM! % 1000 == 0 ? 0 : 1))} ${l10n.unitKm}';

    String categoryOf(String id) {
      final c = categories.where((c) => c.id == id).firstOrNull;
      return c == null ? '' : l10n.categoryLabel(c);
    }

    Widget line(
      String label,
      String value, {
      Color? color,
      bool bold = false,
    }) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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
            style: (bold ? theme.textTheme.titleMedium : null)?.copyWith(
              color: color,
              fontWeight: bold ? FontWeight.w700 : null,
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(route.isEmpty ? l10n.tripTitle : route),
        actions: [
          IconButton(
            tooltip: l10n.editTrip,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/trips/${t.id}/edit'),
          ),
          PopupMenuButton<_Menu>(
            onSelected: (a) => _onMenu(context, ref, a),
            itemBuilder: (_) => [
              PopupMenuItem(value: _Menu.repeat, child: Text(l10n.repeatTrip)),
              PopupMenuItem(
                value: _Menu.returnLeg,
                child: Text(l10n.addReturnLeg),
              ),
              PopupMenuItem(value: _Menu.delete, child: Text(l10n.deleteTrip)),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.gutter),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                children: [
                  line(l10n.tripFare, f.money(t.fare)),
                  line(l10n.expensesTitle, f.money(-ownerExpenses)),
                  line(l10n.driverPayLabel, f.money(-t.driverPay)),
                  const Divider(),
                  line(
                    profit.isNegative ? l10n.lossLabel : l10n.profitLabel,
                    f.money(profit),
                    color: profit.isNegative
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                    bold: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    t.status == PaymentStatus.paid
                        ? Icons.check_circle_outline
                        : Icons.hourglass_bottom,
                  ),
                  title: Text(l10n.paymentName(t.status)),
                  subtitle: t.status == PaymentStatus.paid
                      ? null
                      : Text(
                          '${l10n.amountReceived}: ${f.money(t.received)} · '
                          '${l10n.dueAmount(f.money(t.due))}',
                        ),
                ),
                if (t.status != PaymentStatus.paid)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Spacing.md,
                      0,
                      Spacing.md,
                      Spacing.md,
                    ),
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(Sizes.minTap),
                      ),
                      onPressed: () => _recordPayment(context, ref, t),
                      child: Text(l10n.recordPayment),
                    ),
                  ),
              ],
            ),
          ),
          SectionHeader(l10n.contactDetails),
          if (vehicle != null)
            ListTile(
              leading: const Icon(Icons.directions_car_outlined),
              title: Text(vehicle.nickname),
            ),
          if (driver != null)
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: Text(driver.name),
            ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(
              '${formatDay(f, t.day)}  '
              '${f.digits('${t.startedAt.toLocal().hour.toString().padLeft(2, '0')}:${t.startedAt.toLocal().minute.toString().padLeft(2, '0')}')}',
            ),
          ),
          if (t.distanceM != null)
            ListTile(
              leading: const Icon(Icons.straighten),
              title: Text(distanceText),
            ),
          if (t.loadNote != null)
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(t.loadNote!),
            ),
          if (t.note != null)
            ListTile(leading: const Icon(Icons.notes), title: Text(t.note!)),
          if (t.returnOfTripId != null)
            ListTile(
              leading: const Icon(Icons.u_turn_left),
              title: Text(l10n.returnLegBadge),
              onTap: () => context.push('/trips/${t.returnOfTripId}'),
            ),
          SectionHeader(l10n.expensesTitle),
          if (detail.expenses.isEmpty)
            ListTile(title: Text(l10n.noExpenses))
          else
            for (final e in detail.expenses)
              ListTile(
                title: Text(categoryOf(e.categoryId)),
                subtitle:
                    [
                      if (e.paidBy != PaidBy.owner) l10n.paidByName(e.paidBy),
                      if (e.note != null) e.note!,
                    ].isEmpty
                    ? null
                    : Text(
                        [
                          if (e.paidBy != PaidBy.owner)
                            l10n.paidByName(e.paidBy),
                          if (e.note != null) e.note!,
                        ].join(' · '),
                      ),
                trailing: Text(
                  f.money(e.amount),
                  style: theme.textTheme.titleMedium,
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _onMenu(
    BuildContext context,
    WidgetRef ref,
    _Menu action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final t = detail.trip;
    switch (action) {
      case _Menu.repeat:
        await context.push('/trips/new?repeat=${t.id}');
      case _Menu.returnLeg:
        await context.push('/trips/new?returnOf=${t.id}');
      case _Menu.delete:
        final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.deleteTripTitle),
            content: Text(l10n.deleteTripBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.deleteLabel),
              ),
            ],
          ),
        );
        if (!(ok ?? false) || !context.mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        await ref.read(tripRepositoryProvider).delete(t.id);
        if (context.mounted) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/entries');
          }
        }
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.tripDeleted)));
    }
  }

  Future<void> _recordPayment(BuildContext context, WidgetRef ref, Trip t) {
    return showDialog<void>(
      context: context,
      builder: (_) => _PaymentDialog(trip: t),
    );
  }
}

class _PaymentDialog extends ConsumerStatefulWidget {
  const new({required this.trip});

  final Trip trip;

  @override
  ConsumerState<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<_PaymentDialog> {
  final _amount = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save(Money amount) async {
    final l10n = AppLocalizations.of(context);
    final f = ref.read(numberFormatterProvider);
    final due = widget.trip.due;
    if (!amount.isPositive || amount > due) {
      setState(() => _error = l10n.errPaymentInvalid(f.money(due)));
      return;
    }
    try {
      await ref
          .read(tripRepositoryProvider)
          .recordPayment(widget.trip.id, amount);
    } on TripException {
      if (!mounted) return;
      setState(() => _error = l10n.errPaymentInvalid(f.money(due)));
      return;
    }
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.paymentRecorded)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final f = ref.watch(numberFormatterProvider);
    final due = widget.trip.due;
    return AlertDialog(
      title: Text(l10n.recordPayment),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.dueAmount(f.money(due))),
          const SizedBox(height: Spacing.md),
          TextField(
            controller: _amount,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9০-৯.,]')),
              LengthLimitingTextInputFormatter(14),
            ],
            decoration: InputDecoration(
              labelText: l10n.advanceAmount,
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          TextButton(
            onPressed: () => unawaited(_save(due)),
            child: Text(l10n.markFullyPaid),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final amount = MoneyParser.parseTaka(_amount.text);
            if (amount == null) {
              setState(() => _error = l10n.errPaymentInvalid(f.money(due)));
            } else {
              unawaited(_save(amount));
            }
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
