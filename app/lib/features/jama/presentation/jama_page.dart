import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/amount_sheet.dart';
import 'package:vehicle_khata/app/ui/widgets/big_button.dart';
import 'package:vehicle_khata/app/ui/widgets/empty_state.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/money/number_formatter.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/jama/data/jama_repository.dart';
import 'package:vehicle_khata/features/jama/domain/jama_logic.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

String jamaErrorText(AppLocalizations l10n, Object e) => switch (e) {
  JamaException(error: JamaError.exceedsDue) => l10n.jamaErrExceeds,
  JamaException(error: JamaError.nothingDue) => l10n.jamaErrNothing,
  JamaException(error: JamaError.depositExceedsBalance) => l10n.jamaErrDeposit,
  _ => l10n.jamaErrGeneric,
};

String jamaDate(NumberFormatter f, CalendarDay d) => f.digits(
  '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}',
);

/// One vehicle's jama: collect, see the month, and handle garage and deposit.
class JamaPage extends ConsumerStatefulWidget {
  const new({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  ConsumerState<JamaPage> createState() => _JamaPageState();
}

class _JamaPageState extends ConsumerState<JamaPage> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final t = ref.read(todayProvider);
    _year = t.year;
    _month = t.month;
    // Catches up on anything due since the app was last open.
    unawaited(ref.read(jamaRepositoryProvider).generate(t));
  }

  void _shift(int by) {
    final d = CalendarDay.of(_year, _month + by, 1);
    setState(() {
      _year = d.year;
      _month = d.month;
    });
  }

  void _say(String text, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          action: action,
          persist: false,
          duration: const Duration(seconds: 5),
        ),
      );
  }

  Future<void> _collect(Assignment a, Money amount) async {
    final l10n = AppLocalizations.of(context);
    final f = ref.read(numberFormatterProvider);
    final repo = ref.read(jamaRepositoryProvider);
    final today = ref.read(todayProvider);
    try {
      final id = await repo.collect(
        assignmentId: a.id,
        amount: amount,
        day: today,
        today: today,
      );
      if (!mounted) return;
      _say(
        l10n.jamaCollected(f.money(amount)),
        action: SnackBarAction(
          label: l10n.jamaUndo,
          onPressed: () => repo.voidPayment(id),
        ),
      );
    } on Object catch (e) {
      if (mounted) _say(jamaErrorText(l10n, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final f = ref.watch(numberFormatterProvider);
    final active = ref.watch(activeAssignmentProvider(widget.vehicleId));
    final today = ref.watch(todayProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.jamaTitle)),
      body: SafeArea(
        child: active.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) =>
              EmptyState(icon: Icons.error_outline, title: l10n.errUnknown),
          data: (view) {
            final model = view?.assignment.payModel;
            if (view == null || model is! JamaPay) {
              return EmptyState(
                icon: Icons.event_busy_outlined,
                title: l10n.jamaNoDriver,
              );
            }
            final a = view.assignment;
            final baki =
                ref.watch(jamaBakiProvider(widget.vehicleId)).value ??
                Money.zero;
            final quick = baki < model.amount ? baki : model.amount;
            final theme = Theme.of(context);
            return ListView(
              padding: const EdgeInsets.all(Spacing.gutter),
              children: [
                Text(
                  l10n.jamaDriverLine(
                    view.driverName,
                    f.money(model.amount),
                    model.frequency == JamaFrequency.daily
                        ? l10n.jamaDaily
                        : l10n.jamaWeekly,
                  ),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: Spacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.jamaBaki,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    Text(
                      f.money(baki),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: baki.isPositive
                            ? AppColors.expense
                            : AppColors.income,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                BigButton(
                  label: baki.isPositive
                      ? l10n.jamaCollect(f.money(quick))
                      : l10n.jamaAllPaid,
                  icon: Icons.payments_outlined,
                  onPressed: baki.isPositive ? () => _collect(a, quick) : null,
                ),
                const SizedBox(height: Spacing.sm),
                BigButton(
                  label: l10n.jamaOtherAmount,
                  style: BigButtonStyle.outlined,
                  onPressed: baki.isPositive
                      ? () async {
                          final amount = await showAmountSheet(
                            context,
                            title: l10n.jamaCollectTitle,
                            initial: quick,
                          );
                          if (amount != null && amount.isPositive) {
                            await _collect(a, amount);
                          }
                        }
                      : null,
                ),
                const SizedBox(height: Spacing.lg),
                _MonthCalendar(
                  vehicleId: widget.vehicleId,
                  year: _year,
                  month: _month,
                  today: today,
                  onPrev: () => _shift(-1),
                  onNext: () => _shift(1),
                ),
                const SizedBox(height: Spacing.lg),
                _Payments(assignmentId: a.id),
                const SizedBox(height: Spacing.lg),
                _Garage(vehicleId: widget.vehicleId, today: today),
                const SizedBox(height: Spacing.lg),
                _Deposit(assignmentId: a.id, today: today),
              ],
            );
          },
        ),
      ),
    );
  }
}

Color _statusColor(JamaStatus s) => switch (s) {
  JamaStatus.paid => const Color(0xFF2E9E5B),
  JamaStatus.partial => const Color(0xFFE0A100),
  JamaStatus.unpaid => const Color(0xFFD64545),
  JamaStatus.waived => const Color(0xFF6C8EBF),
  JamaStatus.none => const Color(0xFFBDBDBD),
};

String _statusText(AppLocalizations l10n, JamaStatus s) => switch (s) {
  JamaStatus.paid => l10n.jamaStatusPaid,
  JamaStatus.partial => l10n.jamaStatusPartial,
  JamaStatus.unpaid => l10n.jamaStatusUnpaid,
  JamaStatus.waived => l10n.jamaStatusWaived,
  JamaStatus.none => l10n.jamaStatusOff,
};

class _MonthCalendar extends ConsumerWidget {
  const new({
    required this.vehicleId,
    required this.year,
    required this.month,
    required this.today,
    required this.onPrev,
    required this.onNext,
  });

  final String vehicleId;
  final int year;
  final int month;
  final CalendarDay today;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final f = ref.watch(numberFormatterProvider);
    final entries =
        ref.watch(jamaMonthProvider((vehicleId, year, month))).value ??
        const [];
    final byDay = {for (final e in entries) e.state.day.epochDay: e};
    final first = CalendarDay.of(year, month, 1);
    // Weeks start on Saturday: Sat=0 .. Fri=6.
    final lead = (first.weekday + 1) % 7;
    final days = first.daysInMonth;

    Widget cell(int dayNum) {
      final day = CalendarDay.of(year, month, dayNum);
      final entry = byDay[day.epochDay];
      final future = day.isAfter(today);
      final status = entry?.state.status ?? JamaStatus.none;
      final color = future && entry == null
          ? Colors.transparent
          : _statusColor(status);
      return Semantics(
        label: '${f.digits('$dayNum')}, ${_statusText(l10n, status)}',
        button: entry != null,
        excludeSemantics: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(Sizes.radius / 2),
          onTap: entry == null ? null : () => _showDay(context, ref, entry, f),
          child: Container(
            margin: const EdgeInsets.all(2),
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: future ? 0 : 0.85),
              border: Border.all(color: color.withValues(alpha: 0.6)),
              borderRadius: BorderRadius.circular(Sizes.radius / 2),
            ),
            child: Text(
              f.digits('$dayNum'),
              style: TextStyle(
                color: future ? null : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    final cells = <Widget>[
      for (var i = 0; i < lead; i++) const SizedBox.shrink(),
      for (var d = 1; d <= days; d++) cell(d),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: l10n.prevMonth,
              onPressed: onPrev,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                f.digits('$year-${month.toString().padLeft(2, '0')}'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: l10n.nextMonth,
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1,
          children: cells,
        ),
        const SizedBox(height: Spacing.sm),
        Wrap(
          spacing: Spacing.md,
          runSpacing: Spacing.xs,
          children: [
            for (final s in [
              JamaStatus.paid,
              JamaStatus.partial,
              JamaStatus.unpaid,
              JamaStatus.waived,
              JamaStatus.none,
            ])
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _statusColor(s),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(_statusText(l10n, s)),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _showDay(
    BuildContext context,
    WidgetRef ref,
    JamaEntryView e,
    NumberFormatter f,
  ) {
    final l10n = AppLocalizations.of(context);
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.gutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${jamaDate(f, e.state.day)} · ${_statusText(l10n, e.state.status)}',
                style: Theme.of(sheet).textTheme.titleMedium,
              ),
              const SizedBox(height: Spacing.sm),
              Text(l10n.jamaDayPaid(f.money(e.state.paid))),
              if (e.state.due.isPositive) ...[
                Text(l10n.jamaDayDue(f.money(e.state.due))),
                const SizedBox(height: Spacing.md),
                BigButton(
                  label: l10n.jamaWaive,
                  style: BigButtonStyle.outlined,
                  onPressed: () async {
                    await ref.read(jamaRepositoryProvider).waive(e.id);
                    if (sheet.mounted) Navigator.pop(sheet);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Payments extends ConsumerWidget {
  const new({required this.assignmentId});

  final String assignmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final f = ref.watch(numberFormatterProvider);
    final list =
        ref.watch(jamaPaymentsProvider(assignmentId)).value ?? const [];
    if (list.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.jamaPayments, style: Theme.of(context).textTheme.titleMedium),
        for (final p in list.take(5))
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(f.money(Money(p.amountMinor))),
            subtitle: Text(jamaDate(f, CalendarDay(p.paidDay))),
            trailing: IconButton(
              tooltip: l10n.jamaVoid,
              icon: const Icon(Icons.undo),
              onPressed: () async {
                await ref.read(jamaRepositoryProvider).voidPayment(p.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(content: Text(l10n.jamaVoided), persist: false),
                    );
                }
              },
            ),
          ),
      ],
    );
  }
}

class _Garage extends ConsumerWidget {
  const new({required this.vehicleId, required this.today});

  final String vehicleId;
  final CalendarDay today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final f = ref.watch(numberFormatterProvider);
    final periods = ref.watch(jamaGarageProvider(vehicleId)).value ?? const [];
    final repo = ref.read(jamaRepositoryProvider);
    final open = periods.where((p) => p.isOpen).firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.jamaGarage, style: Theme.of(context).textTheme.titleMedium),
        for (final p in periods.take(4))
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              p.mode == GarageMode.pause
                  ? Icons.pause_circle_outline
                  : Icons.volunteer_activism_outlined,
            ),
            title: Text(
              p.end == null
                  ? l10n.jamaGarageSince(jamaDate(f, p.start))
                  : l10n.jamaGaragePeriod(
                      jamaDate(f, p.start),
                      jamaDate(f, p.end!),
                    ),
            ),
            subtitle: Text(
              p.mode == GarageMode.pause
                  ? l10n.jamaGaragePause
                  : l10n.jamaGarageWaive,
            ),
          ),
        const SizedBox(height: Spacing.sm),
        if (open != null)
          BigButton(
            label: l10n.jamaGarageBack,
            style: BigButtonStyle.outlined,
            onPressed: () async {
              final end = today.addDays(-1);
              await repo.endGarage(
                open.id,
                end.isBefore(open.start) ? open.start : end,
              );
            },
          )
        else
          BigButton(
            label: l10n.jamaGarageStart,
            style: BigButtonStyle.outlined,
            icon: Icons.car_repair,
            onPressed: () async {
              final mode = await showModalBottomSheet<GarageMode>(
                context: context,
                useRootNavigator: true,
                showDragHandle: true,
                builder: (sheet) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.pause_circle_outline),
                        title: Text(l10n.jamaGaragePause),
                        onTap: () => Navigator.pop(sheet, GarageMode.pause),
                      ),
                      ListTile(
                        leading: const Icon(Icons.volunteer_activism_outlined),
                        title: Text(l10n.jamaGarageWaive),
                        onTap: () => Navigator.pop(sheet, GarageMode.waive),
                      ),
                    ],
                  ),
                ),
              );
              if (mode != null) {
                await repo.startGarage(
                  vehicleId: vehicleId,
                  start: today,
                  mode: mode,
                );
              }
            },
          ),
      ],
    );
  }
}

class _Deposit extends ConsumerStatefulWidget {
  const new({required this.assignmentId, required this.today});

  final String assignmentId;
  final CalendarDay today;

  @override
  ConsumerState<_Deposit> createState() => _DepositState();
}

class _DepositState extends ConsumerState<_Deposit> {
  int _version = 0;

  Future<void> _add(DepositKind kind, String title) async {
    final l10n = AppLocalizations.of(context);
    final amount = await showAmountSheet(context, title: title);
    if (amount == null || !amount.isPositive) return;
    try {
      await ref
          .read(jamaRepositoryProvider)
          .addDeposit(
            assignmentId: widget.assignmentId,
            kind: kind,
            amount: amount,
            day: widget.today,
          );
      if (mounted) setState(() => _version++);
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(jamaErrorText(l10n, e)), persist: false),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final f = ref.watch(numberFormatterProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.jamaDeposit, style: Theme.of(context).textTheme.titleMedium),
        FutureBuilder<Money>(
          key: ValueKey(_version),
          future: ref
              .read(jamaRepositoryProvider)
              .depositBalance(widget.assignmentId),
          builder: (context, snap) =>
              Text(l10n.jamaDepositBalance(f.money(snap.data ?? Money.zero))),
        ),
        const SizedBox(height: Spacing.sm),
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: [
            OutlinedButton(
              onPressed: () => _add(DepositKind.received, l10n.jamaDepositAdd),
              child: Text(l10n.jamaDepositAdd),
            ),
            OutlinedButton(
              onPressed: () => _add(DepositKind.refund, l10n.jamaDepositRefund),
              child: Text(l10n.jamaDepositRefund),
            ),
            OutlinedButton(
              onPressed: () => _add(DepositKind.deduct, l10n.jamaDepositDeduct),
              child: Text(l10n.jamaDepositDeduct),
            ),
          ],
        ),
      ],
    );
  }
}
