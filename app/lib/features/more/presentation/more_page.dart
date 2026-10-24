import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_khata/app/flavor.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/widgets/khata_list_tile.dart';
import 'package:vehicle_khata/core/sync/sync_engine.dart';
import 'package:vehicle_khata/dev/seed_data.dart';
import 'package:vehicle_khata/features/sync/presentation/sync_page.dart';
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
          if (ref.watch(syncEngineProvider) != null)
            KhataListTile(
              icon: Icons.cloud_sync_outlined,
              title: l10n.syncTitle,
              subtitle: syncPhaseText(
                l10n,
                ref.watch(syncStatusProvider).value ?? const SyncStatus(),
              ),
              onTap: () => context.go('/more/sync'),
            ),
          KhataListTile(
            icon: Icons.ios_share,
            title: l10n.exportTitle,
            onTap: () => context.go('/more/export'),
          ),
          KhataListTile(
            icon: Icons.badge_outlined,
            title: l10n.driversTitle,
            onTap: () => context.push('/drivers'),
          ),
          KhataListTile(
            icon: Icons.label_outline,
            title: l10n.expenseCategories,
            onTap: () => context.go('/more/categories'),
          ),
          KhataListTile(
            icon: Icons.settings_outlined,
            title: l10n.settings,
            onTap: () => context.go('/more/settings'),
          ),
          if (ref.watch(flavorProvider) != Flavor.prod)
            KhataListTile(
              icon: Icons.science_outlined,
              title: l10n.generateDemo,
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                await seedDemoData(ref.read(appDatabaseProvider));
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(l10n.demoDone)));
              },
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
