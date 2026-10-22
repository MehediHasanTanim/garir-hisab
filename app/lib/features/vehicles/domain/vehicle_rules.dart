/// Validation and normalisation rules for vehicles (pure Dart).
abstract final class VehicleRules {
  static const maxNicknameLength = 40;
  static const minYear = 1970;

  /// Trims and collapses whitespace.
  static String cleanText(String input) =>
      input.trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Returns null when valid, otherwise a [NicknameError].
  static NicknameError? validateNickname(String input) {
    final cleaned = cleanText(input);
    if (cleaned.isEmpty) return NicknameError.empty;
    if (cleaned.length > maxNicknameLength) return NicknameError.tooLong;
    return null;
  }

  /// Key used to detect duplicate registration numbers: letters/digits only,
  /// lower-cased, Bangla digits converted to Latin. Empty input yields null.
  static String? regNoKey(String? input) {
    if (input == null) return null;
    final latin = _banglaToLatin(input);
    final key = latin.toLowerCase().replaceAll(
      RegExp(r'[^\p{L}\p{M}\p{N}]', unicode: true),
      '',
    );
    return key.isEmpty ? null : key;
  }

  /// Display form of a registration number (cleaned text), or null if empty.
  static String? cleanRegNo(String? input) {
    if (input == null) return null;
    final cleaned = cleanText(input);
    return cleaned.isEmpty ? null : cleaned;
  }

  /// Null when valid.
  static bool isValidYear(int? year, {required int currentYear}) =>
      year == null || (year >= minYear && year <= currentYear + 1);

  static String _banglaToLatin(String s) {
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

enum NicknameError { empty, tooLong }
