import 'package:flutter/material.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/money/number_formatter.dart';

/// Money text coloured by sign (green income, red expense, neutral zero).
class AmountText extends StatelessWidget {
  const new({
    required this.amount,
    required this.formatter,
    this.style,
    super.key,
  });

  final Money amount;
  final NumberFormatter formatter;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.titleMedium;
    final color = amount.isNegative
        ? AppColors.expense
        : amount.isPositive
        ? AppColors.income
        : null;
    return Text(
      formatter.money(amount),
      style: base?.copyWith(color: color, fontWeight: FontWeight.w600),
    );
  }
}

/// Standard list row: icon, title/subtitle and an optional amount.
class KhataListTile extends StatelessWidget {
  const new({
    required this.title,
    this.subtitle,
    this.icon,
    this.amount,
    this.formatter,
    this.onTap,
    super.key,
  }) : assert(
         amount == null || formatter != null,
         'formatter is required when amount is set',
       );

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Money? amount;
  final NumberFormatter? formatter;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      minTileHeight: 64,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
      leading: icon == null
          ? null
          : CircleAvatar(
              backgroundColor: scheme.secondaryContainer,
              child: Icon(icon, color: scheme.onSecondaryContainer),
            ),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: amount == null
          ? null
          : AmountText(amount: amount!, formatter: formatter!),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const new(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.gutter,
        Spacing.lg,
        Spacing.gutter,
        Spacing.sm,
      ),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}
