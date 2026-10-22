import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/amount_keypad.dart';
import 'package:vehicle_khata/app/ui/widgets/big_button.dart';
import 'package:vehicle_khata/app/ui/widgets/empty_state.dart';
import 'package:vehicle_khata/app/ui/widgets/khata_list_tile.dart';
import 'package:vehicle_khata/app/ui/widgets/quick_chips.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// Storybook-style catalogue of the core widgets.
class GalleryPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formatter = ref.watch(numberFormatterProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.uiGallery)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Spacing.xl),
        children: [
          SectionHeader(l10n.galleryButtons),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
            child: Column(
              children: [
                BigButton(
                  label: l10n.addIncome,
                  icon: Icons.add,
                  onPressed: () {},
                ),
                const SizedBox(height: Spacing.sm),
                BigButton(
                  label: l10n.addIncome,
                  style: BigButtonStyle.tonal,
                  onPressed: () {},
                ),
                const SizedBox(height: Spacing.sm),
                BigButton(
                  label: l10n.addIncome,
                  style: BigButtonStyle.outlined,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          SectionHeader(l10n.galleryChips),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
            child: QuickChips<String>(
              onSelected: (_) {},
              chips: [
                QuickChipData(
                  value: 'fuel',
                  label: l10n.chipFuel,
                  icon: Icons.local_gas_station_outlined,
                ),
                QuickChipData(
                  value: 'toll',
                  label: l10n.chipToll,
                  icon: Icons.toll_outlined,
                ),
                QuickChipData(
                  value: 'parking',
                  label: l10n.chipParking,
                  icon: Icons.local_parking_outlined,
                ),
                QuickChipData(
                  value: 'helper',
                  label: l10n.chipHelper,
                  icon: Icons.engineering_outlined,
                ),
              ],
            ),
          ),
          SectionHeader(l10n.galleryTiles),
          KhataListTile(
            icon: Icons.payments_outlined,
            title: l10n.galleryTileTitle,
            subtitle: l10n.galleryTileSubtitle,
            amount: const Money.taka(600),
            formatter: formatter,
          ),
          KhataListTile(
            icon: Icons.local_gas_station_outlined,
            title: l10n.chipFuel,
            amount: const Money.taka(-1250),
            formatter: formatter,
          ),
          SectionHeader(l10n.galleryKeypad),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
            child: AmountKeypad(
              formatter: formatter,
              doneLabel: l10n.keypadDone,
              deleteLabel: l10n.keypadDelete,
              onChanged: (_) {},
              onDone: (_) {},
            ),
          ),
          SectionHeader(l10n.galleryEmpty),
          SizedBox(
            height: 260,
            child: EmptyState(
              icon: Icons.inbox_outlined,
              title: l10n.entriesEmptyTitle,
              message: l10n.entriesEmptyMessage,
            ),
          ),
        ],
      ),
    );
  }
}
