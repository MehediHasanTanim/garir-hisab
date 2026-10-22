import 'package:flutter/material.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/features/app_lock/domain/pin_hasher.dart';

/// Dots + numeric pad. Calls [onCompleted] when [PinHasher.pinLength] digits
/// are entered; a returned string is shown as an error and the pad resets.
class PinEntry extends StatefulWidget {
  const new({
    required this.title,
    required this.onCompleted,
    required this.deleteLabel,
    this.biometricLabel,
    this.onBiometric,
    this.digitLabel,
    this.initialError,
    super.key,
  });

  final String title;
  final Future<String?> Function(String pin) onCompleted;
  final String deleteLabel;

  /// Shows a fingerprint key when both are provided.
  final String? biometricLabel;
  final VoidCallback? onBiometric;

  /// Maps a Latin digit to its display form (e.g. Bangla numerals).
  final String Function(String digit)? digitLabel;

  /// Error shown until the first digit is entered (e.g. after a reset).
  final String? initialError;

  @override
  State<PinEntry> createState() => _PinEntryState();
}

class _PinEntryState extends State<PinEntry> {
  String _pin = '';
  late String? _error = widget.initialError;
  bool _busy = false;

  Future<void> _add(String d) async {
    if (_busy || _pin.length >= PinHasher.pinLength) return;
    setState(() {
      _pin += d;
      _error = null;
    });
    if (_pin.length == PinHasher.pinLength) {
      setState(() => _busy = true);
      final error = await widget.onCompleted(_pin);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _pin = '';
        _error = error;
      });
    }
  }

  void _backspace() {
    if (_busy || _pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = widget.digitLabel ?? (d) => d;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: Text(
            widget.title,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: Spacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < PinHasher.pinLength; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _pin.length
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(
          height: 48,
          child: Center(
            child: _error == null
                ? null
                : Text(
                    _error!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          _row([for (final d in row) _digit(d, label(d))]),
        _row([
          if (widget.onBiometric != null && widget.biometricLabel != null)
            _iconKey(
              Icons.fingerprint,
              widget.biometricLabel!,
              widget.onBiometric!,
            )
          else
            const SizedBox.shrink(),
          _digit('0', label('0')),
          _iconKey(Icons.backspace_outlined, widget.deleteLabel, _backspace),
        ]),
      ],
    );
  }

  Widget _row(List<Widget> keys) => Padding(
    padding: const EdgeInsets.only(bottom: Spacing.sm),
    child: Row(
      children: [
        for (var i = 0; i < keys.length; i++) ...[
          if (i > 0) const SizedBox(width: Spacing.sm),
          Expanded(child: keys[i]),
        ],
      ],
    ),
  );

  Widget _digit(String value, String shown) => FilledButton.tonal(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(Sizes.keypadKeyHeight),
    ),
    onPressed: () => _add(value),
    child: Text(shown, style: Theme.of(context).textTheme.headlineSmall),
  );

  Widget _iconKey(IconData icon, String label, VoidCallback onTap) =>
      FilledButton.tonal(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(Sizes.keypadKeyHeight),
        ),
        onPressed: onTap,
        child: Icon(icon, semanticLabel: label),
      );
}
