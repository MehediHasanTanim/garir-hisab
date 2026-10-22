import 'package:flutter/material.dart';
import 'package:vehicle_khata/app/ui/widgets/empty_state.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

class HomePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navHome)),
      body: EmptyState(
        icon: Icons.directions_car_outlined,
        title: l10n.homeEmptyTitle,
        message: l10n.homeEmptyMessage,
      ),
    );
  }
}
