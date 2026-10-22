import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/l10n_labels.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/vehicle_icons.dart';
import 'package:vehicle_khata/app/ui/widgets/big_button.dart';
import 'package:vehicle_khata/features/auth/presentation/auth_flow.dart';
import 'package:vehicle_khata/features/onboarding/domain/onboarding_state.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_rules.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

class OnboardingPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(onboardingProvider);
    final formatter = ref.watch(numberFormatterProvider);
    final canGoBack =
        state.step != OnboardingStep.language &&
        state.step != OnboardingStep.done;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: canGoBack
            ? IconButton(
                tooltip: l10n.backLabel,
                icon: const Icon(Icons.arrow_back),
                onPressed: () => ref.read(onboardingProvider.notifier).back(),
              )
            : null,
        title: Text(
          l10n.onbStepOf(
            formatter.digits('${state.stepNumber}'),
            formatter.digits('${OnboardingState.totalSteps}'),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: state.stepNumber / OnboardingState.totalSteps,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.gutter),
          child: switch (state.step) {
            OnboardingStep.language => const _LanguageStep(),
            OnboardingStep.account => const _AccountStep(),
            OnboardingStep.role => const _RoleStep(),
            OnboardingStep.vehicle => const _VehicleStep(),
            OnboardingStep.model || OnboardingStep.done => const _ModelStep(),
          },
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const new(this.title, {this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: theme.textTheme.headlineSmall),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: Spacing.sm),
            Text(
              subtitle!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const new({
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.icon,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Material(
        color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Sizes.radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(Sizes.radius),
          onTap: enabled ? onTap : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: enabled ? null : scheme.outline),
                    const SizedBox(width: Spacing.md),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: enabled ? null : scheme.outline,
                              ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                  if (selected) Icon(Icons.check_circle, color: scheme.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageStep extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Title(l10n.welcomeTitle, subtitle: l10n.welcomeSubtitle),
        Text(
          l10n.chooseLanguage,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: Spacing.sm),
        _ChoiceTile(
          title: l10n.languageBangla,
          selected: settings.languageCode == 'bn',
          onTap: () => notifier.setLanguage('bn'),
        ),
        _ChoiceTile(
          title: l10n.languageEnglish,
          selected: settings.languageCode == 'en',
          onTap: () => notifier.setLanguage('en'),
        ),
        const SizedBox(height: Spacing.lg),
        BigButton(
          label: l10n.continueLabel,
          onPressed: () => ref.read(onboardingProvider.notifier).languageDone(),
        ),
      ],
    );
  }
}

class _AccountStep extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authRepositoryProvider);
    final user = ref.watch(authUserProvider).value ?? auth.currentUser;
    final notifier = ref.read(onboardingProvider.notifier);
    final formatter = ref.watch(numberFormatterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Title(l10n.accountTitle, subtitle: l10n.accountSubtitle),
        if (user != null) ...[
          Text(
            l10n.signedInAs(formatter.digits(user.phone)),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: Spacing.lg),
          BigButton(label: l10n.continueLabel, onPressed: notifier.accountDone),
        ] else if (!auth.isConfigured) ...[
          Text(l10n.signInUnavailable),
          const SizedBox(height: Spacing.sm),
          Text(l10n.localOnlyNote),
          const SizedBox(height: Spacing.lg),
          BigButton(
            label: l10n.continueWithoutAccount,
            onPressed: notifier.accountDone,
          ),
        ] else ...[
          AuthFlow(onSignedIn: (_) => notifier.accountDone()),
          const SizedBox(height: Spacing.lg),
          Text(
            l10n.localOnlyNote,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: notifier.accountDone,
            child: Text(l10n.continueWithoutAccount),
          ),
        ],
      ],
    );
  }
}

class _RoleStep extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(onboardingProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Title(l10n.roleTitle),
        _ChoiceTile(
          title: l10n.roleOwner,
          subtitle: l10n.roleOwnerDesc,
          icon: Icons.key_outlined,
          selected: false,
          onTap: () => notifier.chooseRole(UserRole.owner),
        ),
        _ChoiceTile(
          title: l10n.roleDriver,
          subtitle: l10n.comingSoon,
          icon: Icons.drive_eta_outlined,
          selected: false,
          enabled: false,
          onTap: () {},
        ),
      ],
    );
  }
}

class _VehicleStep extends ConsumerStatefulWidget {
  const new();

  @override
  ConsumerState<_VehicleStep> createState() => _VehicleStepState();
}

class _VehicleStepState extends ConsumerState<_VehicleStep> {
  late final _nickname = TextEditingController(
    text: ref.read(onboardingProvider).vehicleNickname,
  );
  late VehicleType _type = ref.read(onboardingProvider).vehicleType;
  String? _error;

  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  void _next() {
    final l10n = AppLocalizations.of(context);
    final err = VehicleRules.validateNickname(_nickname.text);
    if (err != null) {
      setState(() {
        _error = err == NicknameError.empty
            ? l10n.errNicknameEmpty
            : l10n.errNicknameTooLong(
                ref
                    .read(numberFormatterProvider)
                    .digits('${VehicleRules.maxNicknameLength}'),
              );
      });
      return;
    }
    unawaited(
      ref
          .read(onboardingProvider.notifier)
          .saveVehicleBasics(nickname: _nickname.text, type: _type),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Title(l10n.firstVehicleTitle),
        TextField(
          controller: _nickname,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: l10n.vehicleNickname,
            hintText: l10n.vehicleNicknameHint,
            errorText: _error,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onSubmitted: (_) => _next(),
        ),
        const SizedBox(height: Spacing.lg),
        Text(l10n.vehicleType, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: Spacing.sm),
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: [
            for (final t in VehicleType.values)
              ChoiceChip(
                avatar: Icon(vehicleIcon(t), size: 20),
                label: Text(l10n.vehicleTypeName(t)),
                selected: _type == t,
                onSelected: (_) => setState(() => _type = t),
              ),
          ],
        ),
        const SizedBox(height: Spacing.xl),
        BigButton(label: l10n.continueLabel, onPressed: _next),
        TextButton(
          onPressed: () => ref.read(onboardingProvider.notifier).skipVehicle(),
          child: Text(l10n.skipForNow),
        ),
      ],
    );
  }
}

class _ModelStep extends ConsumerStatefulWidget {
  const new();

  @override
  ConsumerState<_ModelStep> createState() => _ModelStepState();
}

class _ModelStepState extends ConsumerState<_ModelStep> {
  late BusinessModel _model = ref
      .read(onboardingProvider)
      .vehicleType
      .defaultModel;
  bool _saving = false;

  Future<void> _finish() async {
    setState(() => _saving = true);
    await ref.read(onboardingProvider.notifier).finish(_model);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Title(l10n.modelTitle),
        for (final m in BusinessModel.values)
          _ChoiceTile(
            title: l10n.modelName(m),
            subtitle: l10n.modelDescription(m),
            icon: modelIcon(m),
            selected: _model == m,
            onTap: () => setState(() => _model = m),
          ),
        const SizedBox(height: Spacing.lg),
        BigButton(label: l10n.finishSetup, onPressed: _saving ? null : _finish),
      ],
    );
  }
}
