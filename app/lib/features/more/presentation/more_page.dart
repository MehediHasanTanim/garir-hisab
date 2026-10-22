import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/widgets/khata_list_tile.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

class MorePage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authUserProvider).value;
    final formatter = ref.watch(numberFormatterProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMore)),
      body: ListView(
        children: [
          KhataListTile(
            icon: Icons.account_circle_outlined,
            title: l10n.account,
            subtitle: user == null
                ? l10n.signInToBackUp
                : formatter.digits(user.phone),
            onTap: () => context.go('/more/account'),
          ),
          KhataListTile(
            icon: Icons.badge_outlined,
            title: l10n.driversTitle,
            onTap: () => context.push('/drivers'),
          ),
          KhataListTile(
            icon: Icons.settings_outlined,
            title: l10n.settings,
            onTap: () => context.go('/more/settings'),
          ),
          KhataListTile(
            icon: Icons.widgets_outlined,
            title: l10n.uiGallery,
            onTap: () => context.go('/more/gallery'),
          ),
        ],
      ),
    );
  }
}
