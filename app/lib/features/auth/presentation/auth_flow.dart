import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/l10n_labels.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/big_button.dart';
import 'package:vehicle_khata/features/auth/domain/auth_repository.dart';
import 'package:vehicle_khata/features/auth/domain/phone_number.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// How long before another code may be requested.
final resendCooldownProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 60),
);

enum _Stage { phone, code }

/// Phone-number entry followed by 6-digit OTP verification.
class AuthFlow extends ConsumerStatefulWidget {
  const new({required this.onSignedIn, super.key});

  final ValueChanged<AuthUser> onSignedIn;

  @override
  ConsumerState<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends ConsumerState<AuthFlow> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  _Stage _stage = _Stage.phone;
  String? _e164;
  String? _error;
  bool _busy = false;
  int _secondsLeft = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _secondsLeft = ref.read(resendCooldownProvider).inSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _secondsLeft = (_secondsLeft - 1).clamp(0, 1 << 30));
      if (_secondsLeft == 0) t.cancel();
    });
  }

  Future<void> _sendCode() async {
    final l10n = AppLocalizations.of(context);
    final e164 = PhoneNumber.normalizeBd(_phone.text);
    if (e164 == null) {
      setState(() => _error = l10n.errInvalidPhone);
      return;
    }
    await _run(() async {
      await ref.read(authRepositoryProvider).sendOtp(e164);
      _e164 = e164;
      _code.clear();
      _stage = _Stage.code;
      _startCooldown();
    });
  }

  Future<void> _verify() async {
    final e164 = _e164;
    if (e164 == null) return;
    final l10n = AppLocalizations.of(context);
    final code = _code.text.trim();
    if (code.length != 6) {
      setState(() => _error = l10n.errInvalidCode);
      return;
    }
    AuthUser? signedIn;
    await _run(() async {
      signedIn = await ref
          .read(authRepositoryProvider)
          .verifyOtp(phoneE164: e164, code: code);
    });
    final user = signedIn;
    if (user != null && mounted) widget.onSignedIn(user);
  }

  Future<void> _run(Future<void> Function() body) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await body();
    } on AuthException catch (e) {
      if (!mounted) return;
      _error = AppLocalizations.of(context).authFailure(e.failure);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatter = ref.watch(numberFormatterProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_stage == _Stage.phone) ...[
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.telephoneNumber],
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9০-৯+\s\-]')),
              LengthLimitingTextInputFormatter(18),
            ],
            decoration: InputDecoration(
              labelText: l10n.phoneLabel,
              hintText: l10n.phoneHint,
              prefixText: '${PhoneNumber.countryCode} ',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _sendCode(),
          ),
          const SizedBox(height: Spacing.md),
          BigButton(label: l10n.sendCode, onPressed: _busy ? null : _sendCode),
        ] else ...[
          Text(
            l10n.otpSentTo(
              formatter.digits(PhoneNumber.formatLocal(_e164 ?? '')),
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: Spacing.md),
          TextField(
            controller: _code,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.oneTimeCode],
            autofocus: true,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(letterSpacing: 8),
            decoration: InputDecoration(
              labelText: l10n.otpLabel,
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) {
              if (v.length == 6 && !_busy) unawaited(_verify());
            },
            onSubmitted: (_) => _verify(),
          ),
          const SizedBox(height: Spacing.sm),
          BigButton(label: l10n.verify, onPressed: _busy ? null : _verify),
          const SizedBox(height: Spacing.sm),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() {
                        _stage = _Stage.phone;
                        _error = null;
                        _timer?.cancel();
                      }),
                child: Text(l10n.changeNumber),
              ),
              TextButton(
                onPressed: _busy || _secondsLeft > 0 ? null : _sendCode,
                child: Text(
                  _secondsLeft > 0
                      ? l10n.resendIn(formatter.digits('$_secondsLeft'))
                      : l10n.resendCode,
                ),
              ),
            ],
          ),
        ],
        if (_busy)
          const Padding(
            padding: EdgeInsets.only(top: Spacing.md),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }
}
