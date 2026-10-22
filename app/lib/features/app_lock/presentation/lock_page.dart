import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/features/app_lock/presentation/app_lock_controller.dart';
import 'package:vehicle_khata/features/app_lock/presentation/pin_entry.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// Full-screen PIN lock. Unlocking flips [appLockProvider]; the router then
/// leaves this page.
class LockPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<LockPage> createState() => _LockPageState();
}

class _LockPageState extends ConsumerState<LockPage> {
  bool _promptedBiometric = false;

  Future<void> _biometric() async {
    final l10n = AppLocalizations.of(context);
    await ref
        .read(appLockProvider.notifier)
        .unlockWithBiometric(l10n.biometricReason);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_promptedBiometric && ref.read(appLockProvider).biometricEnabled) {
      _promptedBiometric = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_biometric());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatter = ref.watch(numberFormatterProvider);
    final lock = ref.watch(appLockProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Spacing.gutter),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 48),
                    const SizedBox(height: Spacing.md),
                    PinEntry(
                      title: l10n.enterPin,
                      deleteLabel: l10n.keypadDelete,
                      digitLabel: formatter.digits,
                      biometricLabel: lock.biometricEnabled
                          ? l10n.useBiometric
                          : null,
                      onBiometric: lock.biometricEnabled ? _biometric : null,
                      onCompleted: (pin) async {
                        final controller = ref.read(appLockProvider.notifier);
                        final result = await controller.unlockWithPin(pin);
                        return switch (result) {
                          UnlockResult.success => null,
                          UnlockResult.wrongPin => l10n.wrongPin,
                          UnlockResult.blocked => l10n.pinBlocked(
                            formatter.digits(
                              '${(controller.blockedFor()?.inSeconds ?? 0) + 1}',
                            ),
                          ),
                        };
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
