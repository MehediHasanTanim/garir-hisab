import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_khata/app/l10n_labels.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/format.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/big_button.dart';
import 'package:vehicle_khata/app/ui/widgets/empty_state.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/money/money_parser.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/app_lock/presentation/app_lock_controller.dart';
import 'package:vehicle_khata/features/drivers/data/payout_service.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_calculator.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// Works out and records a payout: earned pay, bonus or penalty, advances
/// recovered, and what to hand over.
class PayoutPage extends ConsumerStatefulWidget {
  const new({required this.driverId, super.key});

  final String driverId;

  @override
  ConsumerState<PayoutPage> createState() => _PayoutPageState();
}

class _PayoutPageState extends ConsumerState<PayoutPage> {
  final _adjustment = TextEditingController();
  final _adjustmentNote = TextEditingController();
  final _note = TextEditingController();
  String? _assignmentId;
  DayRange? _period;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _adjustment.dispose();
    _adjustmentNote.dispose();
    _note.dispose();
    super.dispose();
  }

  void _shiftMonth(DayRange current, int delta) {
    final first = CalendarDay.of(
      current.start.year,
      current.start.month + delta,
      1,
    );
    setState(() => _period = DayRange.month(first.year, first.month));
  }

  Future<void> _pickRange(DayRange current) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 2),
      initialDateRange: DateTimeRange(
        start: current.start.toDate(),
        end: current.end.toDate(),
      ),
    );
    if (picked != null) {
      setState(
        () => _period = DayRange(
          CalendarDay.fromDate(picked.start),
          CalendarDay.fromDate(picked.end),
        ),
      );
    }
  }

  Future<void> _record(PayoutPreviewArgs args) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(payoutServiceProvider)
          .record(
            driverId: args.driverId,
            assignmentId: args.assignmentId,
            period: DayRange(
              CalendarDay(args.startDay),
              CalendarDay(args.endDay),
            ),
            adjustment: Money(args.adjustmentMinor),
            adjustmentNote: _adjustmentNote.text,
            note: _note.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              result.created ? l10n.payoutRecorded : l10n.payoutAlreadyRecorded,
            ),
          ),
        );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/drivers/${widget.driverId}');
      }
    } on PayoutException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = l10n.payoutError(e.error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final formatter = ref.watch(numberFormatterProvider);
    final today = CalendarDay.today(ref.watch(clockProvider));
    final assignments = ref.watch(driverAssignmentsProvider(widget.driverId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.payoutTitle)),
      body: assignments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.errUnknown)),
        data: (all) {
          final payable = all
              .where((v) => v.assignment.payModel is! JamaPay)
              .toList();
          if (payable.isEmpty) {
            return EmptyState(
              icon: Icons.payments_outlined,
              title: l10n.payErrNotPayable,
            );
          }
          final selected = payable.firstWhere(
            (v) => v.assignment.id == _assignmentId,
            orElse: () => payable.first,
          );
          final period = _period ?? DayRange.month(today.year, today.month);
          final adjustment = MoneyParser.parseSignedTaka(_adjustment.text);

          final args = (
            driverId: widget.driverId,
            assignmentId: selected.assignment.id,
            startDay: period.start.epochDay,
            endDay: period.end.epochDay,
            adjustmentMinor: (adjustment ?? Money.zero).minor,
          );
          final preview = ref.watch(payoutPreviewProvider(args));
          final isMonth =
              period == DayRange.month(period.start.year, period.start.month);

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(Spacing.gutter),
                    children: [
                      if (payable.length > 1)
                        DropdownButtonFormField<String>(
                          initialValue: selected.assignment.id,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: l10n.payVehicle,
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            for (final v in payable)
                              DropdownMenuItem(
                                value: v.assignment.id,
                                child: Text(
                                  '${v.vehicleNickname} · '
                                  '${l10n.dateRange(formatDay(formatter, v.assignment.start), v.assignment.end == null ? l10n.ongoing : formatDay(formatter, v.assignment.end!))}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (id) => setState(() => _assignmentId = id),
                        )
                      else
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.directions_car_outlined),
                          title: Text(selected.vehicleNickname),
                          subtitle: Text(
                            payModelSummary(
                              l10n,
                              formatter,
                              selected.assignment.payModel,
                            ),
                          ),
                        ),
                      const SizedBox(height: Spacing.md),
                      Text(l10n.payPeriod, style: theme.textTheme.titleSmall),
                      Row(
                        children: [
                          IconButton(
                            tooltip: l10n.prevMonth,
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () => _shiftMonth(period, -1),
                          ),
                          Expanded(
                            child: Text(
                              isMonth
                                  ? '${monthName(l10n, period.start.month)} ${formatter.digits('${period.start.year}')}'
                                  : l10n.dateRange(
                                      formatDay(formatter, period.start),
                                      formatDay(formatter, period.end),
                                    ),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.nextMonth,
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () => _shiftMonth(period, 1),
                          ),
                        ],
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          onPressed: () => _pickRange(period),
                          icon: const Icon(Icons.date_range_outlined),
                          label: Text(l10n.customRange),
                        ),
                      ),
                      const SizedBox(height: Spacing.sm),
                      preview.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(Spacing.lg),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, _) => Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Spacing.md,
                          ),
                          child: Text(
                            e is PayoutException
                                ? l10n.payoutError(e.error)
                                : l10n.errUnknown,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                        data: (p) => _PreviewCard(preview: p),
                      ),
                      const SizedBox(height: Spacing.md),
                      TextField(
                        controller: _adjustment,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9০-৯.,+\-−]'),
                          ),
                          LengthLimitingTextInputFormatter(15),
                        ],
                        decoration: InputDecoration(
                          labelText: l10n.payAdjustment,
                          errorText: adjustment == null
                              ? l10n.errPriceInvalid
                              : null,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: Spacing.md),
                      TextField(
                        controller: _adjustmentNote,
                        decoration: InputDecoration(
                          labelText: l10n.payAdjustmentNote,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      TextField(
                        controller: _note,
                        decoration: InputDecoration(
                          labelText: l10n.advanceNote,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: Spacing.md),
                          child: Text(
                            _error!,
                            style: TextStyle(color: theme.colorScheme.error),
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
                    label: l10n.recordPayout,
                    icon: Icons.check,
                    onPressed:
                        _saving ||
                            adjustment == null ||
                            !(preview.value?.plan.gross.isPositive ?? false)
                        ? null
                        : () => _record(args),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PreviewCard extends ConsumerWidget {
  const new({required this.preview});

  final PayoutPreview preview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final f = ref.watch(numberFormatterProvider);
    final plan = preview.plan;

    String lineLabel(PayLine line) => switch (line.kind) {
      PayLineKind.salary => l10n.payLineSalary(
        formatHalfDays(f, line.quantity ?? 0),
      ),
      PayLineKind.wages => l10n.payLineWages(
        formatHalfDays(f, line.quantity ?? 0),
      ),
      PayLineKind.tripFees => l10n.payLineTripFees(
        f.digits('${line.quantity ?? 0}'),
      ),
      PayLineKind.commission => l10n.payLineCommission,
    };

    Widget row(String label, String value, {bool bold = false, Color? color}) =>
        Padding(
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
                style: (bold ? theme.textTheme.titleMedium : null)?.copyWith(
                  fontWeight: bold ? FontWeight.w700 : null,
                  color: color,
                ),
              ),
            ],
          ),
        );

    final hasTripPay = switch (preview.assignment.payModel) {
      PerTripPay() || CommissionPay() || MixedPay() => true,
      _ => false,
    };

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (preview.periodWasClipped)
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: Text(
                  l10n.payoutPeriodClipped(
                    formatDay(f, preview.period.start),
                    formatDay(f, preview.period.end),
                  ),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            for (final line in preview.pay.lines)
              row(lineLabel(line), f.money(line.amount)),
            row(l10n.payEarned, f.money(plan.earned), bold: true),
            if (!plan.adjustment.isZero)
              row(l10n.payAdjustment, f.money(plan.adjustment)),
            if (plan.deducted.isPositive)
              row(l10n.payAdvancesDeducted, f.money(-plan.deducted)),
            const Divider(),
            row(l10n.payNet, f.money(plan.net), bold: true),
            if (plan.advancesCarriedOver.isPositive)
              Padding(
                padding: const EdgeInsets.only(top: Spacing.xs),
                child: Text(
                  '${l10n.payAdvancesCarried}: ${f.money(plan.advancesCarriedOver)}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            if (hasTripPay)
              Padding(
                padding: const EdgeInsets.only(top: Spacing.sm),
                child: Text(
                  l10n.payoutTripsNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
