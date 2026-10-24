import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/amount_keypad.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// Asks for a whole-taka amount on the on-screen keypad (no system keyboard).
/// Returns null if dismissed; a zero amount is returned as [Money.zero].
Future<Money?> showAmountSheet(
  BuildContext context, {
  required String title,
  Money initial = Money.zero,
}) {
  return showModalBottomSheet<Money>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _AmountSheet(title: title, initial: initial),
  );
}

class _AmountSheet extends ConsumerWidget {
  const new({required this.title, required this.initial});

  final String title;
  final Money initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formatter = ref.watch(numberFormatterProvider);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.gutter,
          0,
          Spacing.gutter,
          Spacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            AmountKeypad(
              formatter: formatter,
              doneLabel: l10n.keypadDone,
              deleteLabel: l10n.keypadDelete,
              initial: initial,
              onChanged: (_) {},
              onDone: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
      ),
    );
  }
}

/// A tappable row showing a label and an amount (or a hint when empty).
class AmountTile extends StatelessWidget {
  const new({
    required this.label,
    required this.amountText,
    required this.onTap,
    this.hint,
    this.errorText,
    this.emphasis = false,
    super.key,
  });

  final String label;

  /// The formatted amount, or null when nothing has been entered.
  final String? amountText;
  final String? hint;
  final String? errorText;
  final VoidCallback onTap;

  /// Larger text, for the main figure on a form.
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Sizes.radius),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.dialpad),
        ),
        child: Text(
          amountText ?? hint ?? '',
          style:
              (emphasis
                      ? theme.textTheme.headlineSmall
                      : theme.textTheme.titleMedium)
                  ?.copyWith(
                    fontWeight: amountText == null ? null : FontWeight.w700,
                    color: amountText == null
                        ? theme.colorScheme.outline
                        : null,
                  ),
        ),
      ),
    );
  }
}
