/// Bangladesh mobile number handling (pure Dart).
abstract final class PhoneNumber {
  static const countryCode = '+880';

  /// Converts any of `01712345678`, `+8801712345678`, `8801712345678`,
  /// `১৭১২৩৪৫৬৭৮` style input (Bangla digits, spaces, dashes) to E.164
  /// (`+8801712345678`). Returns null when the input is not a valid BD mobile
  /// number.
  static String? normalizeBd(String input) {
    var digits = _toLatinDigits(input).replaceAll(RegExp(r'[\s\-()]'), '');
    if (digits.startsWith('+')) digits = digits.substring(1);
    if (digits.startsWith('880')) {
      digits = digits.substring(3);
    } else if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    // National significant number: 1[3-9] + 8 digits.
    if (!RegExp(r'^1[3-9]\d{8}$').hasMatch(digits)) return null;
    return '$countryCode$digits';
  }

  /// `+8801712345678` -> `01712-345678` for display.
  static String formatLocal(String e164) {
    if (!e164.startsWith(countryCode) || e164.length != 14) return e164;
    final national = '0${e164.substring(4)}';
    return '${national.substring(0, 5)}-${national.substring(5)}';
  }

  static String _toLatinDigits(String s) {
    const bangla = '০১২৩৪৫৬৭৮৯';
    final out = StringBuffer();
    for (final rune in s.runes) {
      final ch = String.fromCharCode(rune);
      final i = bangla.indexOf(ch);
      out.write(i >= 0 ? '$i' : ch);
    }
    return out.toString();
  }
}
