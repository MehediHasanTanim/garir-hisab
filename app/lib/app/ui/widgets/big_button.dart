import 'package:flutter/material.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';

enum BigButtonStyle { primary, tonal, outlined }

/// Full-width, 56 dp primary action.
class BigButton extends StatelessWidget {
  const new({
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = BigButtonStyle.primary,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final BigButtonStyle style;

  @override
  Widget build(BuildContext context) {
    const minSize = WidgetStatePropertyAll(
      Size.fromHeight(Sizes.bigButtonHeight),
    );
    final text = Text(label, textAlign: TextAlign.center);
    final iconWidget = icon == null ? null : Icon(icon);
    const buttonStyle = ButtonStyle(minimumSize: minSize);

    return switch (style) {
      BigButtonStyle.primary => FilledButton.icon(
        onPressed: onPressed,
        icon: iconWidget,
        label: text,
        style: buttonStyle,
      ),
      BigButtonStyle.tonal => FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: iconWidget,
        label: text,
        style: buttonStyle,
      ),
      BigButtonStyle.outlined => OutlinedButton.icon(
        onPressed: onPressed,
        icon: iconWidget,
        label: text,
        style: buttonStyle,
      ),
    };
  }
}
