import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_khata/app/ui/widgets/khata_list_tile.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

class MorePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMore)),
      body: ListView(
        children: [
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
