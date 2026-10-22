import 'package:flutter/material.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';

class QuickChipData<T> {
  const new({required this.value, required this.label, required this.icon});

  final T value;
  final String label;
  final IconData icon;
}

/// Wrapping row of one-tap chips (e.g. fuel / toll / parking).
class QuickChips<T> extends StatelessWidget {
  const new({required this.chips, required this.onSelected, super.key});

  final List<QuickChipData<T>> chips;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        for (final chip in chips)
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Sizes.minTap),
            child: ActionChip(
              avatar: Icon(chip.icon, size: 20),
              label: Text(chip.label),
              onPressed: () => onSelected(chip.value),
            ),
          ),
      ],
    );
  }
}
