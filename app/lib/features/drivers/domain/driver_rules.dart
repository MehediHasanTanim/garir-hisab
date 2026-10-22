import 'package:vehicle_khata/features/auth/domain/phone_number.dart';

enum DriverNameError { empty, tooLong }

/// Validation and normalisation for driver details (pure Dart).
abstract final class DriverRules {
  static const maxNameLength = 60;

  static String clean(String input) =>
      input.trim().replaceAll(RegExp(r'\s+'), ' ');

  static DriverNameError? validateName(String input) {
    final name = clean(input);
    if (name.isEmpty) return DriverNameError.empty;
    if (name.length > maxNameLength) return DriverNameError.tooLong;
    return null;
  }

  /// A valid BD mobile becomes E.164; anything else (a landline, a foreign
  /// number) is kept as typed. Blank becomes null.
  static String? normalizePhone(String? input) {
    if (input == null) return null;
    final text = clean(input);
    if (text.isEmpty) return null;
    return PhoneNumber.normalizeBd(text) ?? text;
  }

  /// Whether [input] is acceptable as a phone number (blank is fine).
  static bool isValidPhone(String? input) {
    if (input == null || clean(input).isEmpty) return true;
    return PhoneNumber.normalizeBd(input) != null;
  }

  /// NID numbers are 10, 13 or 17 digits. Blank is fine (optional).
  static bool isValidNid(String? input) {
    if (input == null) return true;
    final digits = _latin(input).replaceAll(RegExp(r'[\s-]'), '');
    if (digits.isEmpty) return true;
    return RegExp(r'^(\d{10}|\d{13}|\d{17})$').hasMatch(digits);
  }

  /// Digits only, Latin numerals; null when blank.
  static String? normalizeNid(String? input) {
    if (input == null) return null;
    final digits = _latin(input).replaceAll(RegExp(r'[\s-]'), '');
    return digits.isEmpty ? null : digits;
  }

  static String? blankToNull(String? input) {
    if (input == null) return null;
    final text = clean(input);
    return text.isEmpty ? null : text;
  }

  static String _latin(String s) {
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
