import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/features/app_lock/presentation/app_lock_controller.dart';
import 'package:vehicle_khata/features/app_lock/presentation/pin_entry.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

enum PinSetupMode { enable, change, disable }

/// Enable, change or disable the PIN lock.
class PinSetupPage extends ConsumerStatefulWidget {
  const new({required this.mode, super.key});

  final PinSetupMode mode;

  @override
  ConsumerState<PinSetupPage> createState() => _PinSetupPageState();
}

enum _Stage { current, entry, confirm }

class _PinSetupPageState extends ConsumerState<PinSetupPage> {
  late _Stage _stage = widget.mode == PinSetupMode.enable
      ? _Stage.entry
      : _Stage.current;
  late String _currentPin;
  String? _newPin;
  String? _stageError;

  Future<String?> _onCompleted(String pin) async {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(appLockProvider.notifier);

    switch (_stage) {
      case _Stage.current:
        if (widget.mode == PinSetupMode.disable) {
          if (!await controller.disable(pin)) {
            return l10n.wrongPin;
          }
          if (mounted) context.pop();
          return null;
        }
        if (!await controller.verifyPin(pin)) {
          return l10n.wrongPin;
        }
        setState(() {
          _currentPin = pin;
          _stage = _Stage.entry;
        });
      case _Stage.entry:
        setState(() {
          _newPin = pin;
          _stage = _Stage.confirm;
          _stageError = null;
        });
      case _Stage.confirm:
        if (pin != _newPin) {
          setState(() {
            _newPin = null;
            _stage = _Stage.entry;
            _stageError = l10n.pinMismatch;
          });
          return null;
        }
        if (widget.mode == PinSetupMode.change) {
          await controller.changePin(currentPin: _currentPin, newPin: pin);
        } else {
          await controller.enable(pin);
        }
        if (mounted) context.pop();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatter = ref.watch(numberFormatterProvider);
    final title = switch (_stage) {
      _Stage.current => l10n.enterCurrentPin,
      _Stage.entry => l10n.setPinTitle,
      _Stage.confirm => l10n.confirmPinTitle,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(switch (widget.mode) {
          PinSetupMode.enable => l10n.appLock,
          PinSetupMode.change => l10n.changePin,
          PinSetupMode.disable => l10n.turnOffLock,
        }),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.gutter),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: PinEntry(
                // New key per stage so the pad resets.
                key: ValueKey(_stage),
                initialError: _stageError,
                title: title,
                deleteLabel: l10n.keypadDelete,
                digitLabel: formatter.digits,
                onCompleted: _onCompleted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
