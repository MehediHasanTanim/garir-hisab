import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vehicle_khata/app/ui/format.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/money/money_parser.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// Form for choosing and configuring a [PayModel]. Call
/// `PayModelEditorState.submit` (through a [GlobalKey]) to validate: it
/// returns the model, or null after showing the problems inline.
class PayModelEditor extends StatefulWidget {
  const new({required this.allowedTypes, this.initial, super.key});

  final List<PayModelType> allowedTypes;
  final PayModel? initial;

  @override
  State<PayModelEditor> createState() => PayModelEditorState();
}

class PayModelEditorState extends State<PayModelEditor> {
  late PayModelType _type;
  final _monthly = TextEditingController();
  final _perDay = TextEditingController();
  final _halfDay = TextEditingController(text: '50');
  final _perTrip = TextEditingController();
  final _rate = TextEditingController();
  final _jamaAmount = TextEditingController();
  CommissionBasis _basis = CommissionBasis.afterExpenses;
  JamaFrequency _frequency = JamaFrequency.daily;
  Set<int> _offDays = {};
  Set<PayModelField> _errors = {};

  @override
  void initState() {
    super.initState();
    _type = widget.allowedTypes.first;
    final m = widget.initial;
    if (m == null || !widget.allowedTypes.contains(m.type)) return;
    _type = m.type;
    switch (m) {
      case SalaryPay(:final monthly):
        _monthly.text = MoneyParser.formatForEdit(monthly);
      case DailyWagePay(:final perDay, :final halfDayBps):
        _perDay.text = MoneyParser.formatForEdit(perDay);
        _halfDay.text = MoneyParser.formatBasisPoints(halfDayBps);
      case PerTripPay(:final perTrip):
        _perTrip.text = MoneyParser.formatForEdit(perTrip);
      case CommissionPay(:final rateBps, :final basis):
        _rate.text = MoneyParser.formatBasisPoints(rateBps);
        _basis = basis;
      case JamaPay(:final amount, :final frequency, :final offWeekdays):
        _jamaAmount.text = MoneyParser.formatForEdit(amount);
        _frequency = frequency;
        _offDays = {...offWeekdays};
      case MixedPay(:final baseMonthly, :final rateBps, :final basis):
        _monthly.text = MoneyParser.formatForEdit(baseMonthly);
        _rate.text = MoneyParser.formatBasisPoints(rateBps);
        _basis = basis;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _monthly,
      _perDay,
      _halfDay,
      _perTrip,
      _rate,
      _jamaAmount,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Validates the form. Returns the model when valid; otherwise null and the
  /// problems are shown next to the fields.
  PayModel? submit() {
    final problems = <PayModelField>{};

    Money money(TextEditingController c, PayModelField f) {
      final v = MoneyParser.parseTaka(c.text);
      if (v == null) problems.add(f);
      return v ?? Money.zero;
    }

    int percent(TextEditingController c, PayModelField f) {
      final v = MoneyParser.parsePercentToBasisPoints(c.text);
      if (v == null) problems.add(f);
      return v ?? 0;
    }

    final model = switch (_type) {
      PayModelType.salary => SalaryPay(
        monthly: money(_monthly, PayModelField.monthly),
      ),
      PayModelType.dailyWage => DailyWagePay(
        perDay: money(_perDay, PayModelField.perDay),
        halfDayBps: percent(_halfDay, PayModelField.halfDayRate),
      ),
      PayModelType.perTrip => PerTripPay(
        perTrip: money(_perTrip, PayModelField.perTrip),
      ),
      PayModelType.commission => CommissionPay(
        rateBps: percent(_rate, PayModelField.rate),
        basis: _basis,
      ),
      PayModelType.jama => JamaPay(
        amount: money(_jamaAmount, PayModelField.jamaAmount),
        frequency: _frequency,
        offWeekdays: _offDays,
      ),
      PayModelType.mixed => MixedPay(
        baseMonthly: money(_monthly, PayModelField.monthly),
        rateBps: percent(_rate, PayModelField.rate),
        basis: _basis,
      ),
    };
    problems.addAll(model.validate().map((i) => i.field));
    setState(() => _errors = problems);
    return problems.isEmpty ? model : null;
  }

  String? _error(PayModelField field, AppLocalizations l10n) {
    if (!_errors.contains(field)) return null;
    return switch (field) {
      PayModelField.monthly ||
      PayModelField.perDay ||
      PayModelField.perTrip ||
      PayModelField.jamaAmount => l10n.errPayAmount,
      PayModelField.halfDayRate || PayModelField.rate => l10n.errPayRate,
      PayModelField.offDays => l10n.errPayOffDays,
    };
  }

  Widget _field(
    TextEditingController controller,
    String label,
    PayModelField field,
    AppLocalizations l10n,
  ) => Padding(
    padding: const EdgeInsets.only(top: Spacing.md),
    child: TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[0-9০-৯.,]')),
        LengthLimitingTextInputFormatter(14),
      ],
      decoration: InputDecoration(
        labelText: label,
        errorText: _error(field, l10n),
        border: const OutlineInputBorder(),
      ),
    ),
  );

  Widget _basisPicker(AppLocalizations l10n) => Padding(
    padding: const EdgeInsets.only(top: Spacing.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.fBasis, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: Spacing.sm),
        SegmentedButton<CommissionBasis>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: CommissionBasis.beforeExpenses,
              label: Text(l10n.basisBefore),
            ),
            ButtonSegment(
              value: CommissionBasis.afterExpenses,
              label: Text(l10n.basisAfter),
            ),
          ],
          selected: {_basis},
          onSelectionChanged: (s) => setState(() => _basis = s.first),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final fields = switch (_type) {
      PayModelType.salary => [
        _field(_monthly, l10n.fMonthly, PayModelField.monthly, l10n),
      ],
      PayModelType.dailyWage => [
        _field(_perDay, l10n.fPerDay, PayModelField.perDay, l10n),
        _field(_halfDay, l10n.fHalfDay, PayModelField.halfDayRate, l10n),
      ],
      PayModelType.perTrip => [
        _field(_perTrip, l10n.fPerTrip, PayModelField.perTrip, l10n),
      ],
      PayModelType.commission => [
        _field(_rate, l10n.fRate, PayModelField.rate, l10n),
        _basisPicker(l10n),
      ],
      PayModelType.jama => [
        _field(_jamaAmount, l10n.fJamaAmount, PayModelField.jamaAmount, l10n),
        const SizedBox(height: Spacing.md),
        Text(l10n.fFrequency, style: theme.textTheme.titleSmall),
        const SizedBox(height: Spacing.sm),
        SegmentedButton<JamaFrequency>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: JamaFrequency.daily,
              label: Text(l10n.freqDaily),
            ),
            ButtonSegment(
              value: JamaFrequency.weekly,
              label: Text(l10n.freqWeekly),
            ),
          ],
          selected: {_frequency},
          onSelectionChanged: (s) => setState(() => _frequency = s.first),
        ),
        const SizedBox(height: Spacing.md),
        Text(l10n.fOffDays, style: theme.textTheme.titleSmall),
        const SizedBox(height: Spacing.sm),
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: [
            // Bangladesh's week starts on Saturday.
            for (final d in const [6, 7, 1, 2, 3, 4, 5])
              FilterChip(
                label: Text(weekdayShort(l10n, d)),
                selected: _offDays.contains(d),
                onSelected: (on) => setState(() {
                  _offDays = {..._offDays};
                  on ? _offDays.add(d) : _offDays.remove(d);
                }),
              ),
          ],
        ),
        if (_error(PayModelField.offDays, l10n) != null)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.xs),
            child: Text(
              _error(PayModelField.offDays, l10n)!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
      PayModelType.mixed => [
        _field(_monthly, l10n.fBaseSalary, PayModelField.monthly, l10n),
        _field(_rate, l10n.fRate, PayModelField.rate, l10n),
        _basisPicker(l10n),
      ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.payTypeLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: Spacing.sm),
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: [
            for (final t in widget.allowedTypes)
              ChoiceChip(
                label: Text(payTypeName(l10n, t)),
                selected: _type == t,
                onSelected: (_) => setState(() {
                  _type = t;
                  _errors = {};
                }),
              ),
          ],
        ),
        ...fields,
      ],
    );
  }
}
