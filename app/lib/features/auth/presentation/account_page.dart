import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/big_button.dart';
import 'package:vehicle_khata/features/auth/presentation/auth_flow.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// Sign in (to back up data) or sign out, after onboarding.
class AccountPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authRepositoryProvider);
    final user = ref.watch(authUserProvider).value ?? auth.currentUser;
    final formatter = ref.watch(numberFormatterProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.account)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Spacing.gutter),
          children: [
            if (user != null) ...[
              Text(
                l10n.signedInAs(formatter.digits(user.phone)),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: Spacing.lg),
              BigButton(
                label: l10n.signOut,
                style: BigButtonStyle.outlined,
                icon: Icons.logout,
                onPressed: () => ref.read(authRepositoryProvider).signOut(),
              ),
            ] else if (!auth.isConfigured)
              Text(l10n.signInUnavailable)
            else ...[
              Text(
                l10n.signInToBackUp,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: Spacing.lg),
              AuthFlow(onSignedIn: (_) {}),
            ],
          ],
        ),
      ),
    );
  }
}
