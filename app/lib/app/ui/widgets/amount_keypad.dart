import 'package:flutter/material.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/money/number_formatter.dart';

/// Big on-screen numeric keypad for whole-taka amounts (no system keyboard).
class AmountKeypad extends StatefulWidget {
  const new({
    required this.formatter,
    required this.doneLabel,
    required this.deleteLabel,
    required this.onChanged,
    this.onDone,
    this.initial = Money.zero,
    this.maxDigits = 9,
    super.key,
  });

  final NumberFormatter formatter;
  final String doneLabel;
  final String deleteLabel;
  final ValueChanged<Money> onChanged;
  final ValueChanged<Money>? onDone;
  final Money initial;
  final int maxDigits;

  @override
  State<AmountKeypad> createState() => _AmountKeypadState();
}

class _AmountKeypadState extends State<AmountKeypad> {
  late String _digits = widget.initial.isZero
      ? ''
      : (widget.initial.minor ~/ 100).toString();

  Money get _value => Money.taka(_digits.isEmpty ? 0 : int.parse(_digits));

  void _append(String d) {
    final next = _digits + d;
    final trimmed = next.replaceFirst(RegExp('^0+'), '');
    if (trimmed.length > widget.maxDigits) return;
    setState(() => _digits = trimmed);
    widget.onChanged(_value);
  }

  void _backspace() {
    if (_digits.isEmpty) return;
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
    widget.onChanged(_value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.md),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.formatter.money(_value),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          _row([for (final d in row) _key(d, () => _append(d))]),
        _row([
          _key('00', () => _append('00')),
          _key('0', () => _append('0')),
          _iconKey(Icons.backspace_outlined, widget.deleteLabel, _backspace),
        ]),
        const SizedBox(height: Spacing.sm),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(Sizes.bigButtonHeight),
          ),
          onPressed: widget.onDone == null
              ? null
              : () => widget.onDone!(_value),
          child: Text(widget.doneLabel),
        ),
      ],
    );
  }

  Widget _row(List<Widget> keys) => Padding(
    padding: const EdgeInsets.only(bottom: Spacing.sm),
    child: Row(
      children: [
        for (var i = 0; i < keys.length; i++) ...[
          if (i > 0) const SizedBox(width: Spacing.sm),
          Expanded(child: keys[i]),
        ],
      ],
    ),
  );

  Widget _key(String digit, VoidCallback onTap) => FilledButton.tonal(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(Sizes.keypadKeyHeight),
    ),
    onPressed: onTap,
    child: Text(
      widget.formatter.digits(digit),
      style: Theme.of(context).textTheme.headlineSmall,
    ),
  );

  Widget _iconKey(IconData icon, String label, VoidCallback onTap) =>
      FilledButton.tonal(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(Sizes.keypadKeyHeight),
        ),
        onPressed: onTap,
        child: Icon(icon, semanticLabel: label),
      );
}
