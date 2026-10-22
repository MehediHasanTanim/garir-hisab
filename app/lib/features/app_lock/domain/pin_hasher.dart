import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Salted SHA-256 PIN hashing with a constant-time comparison.
abstract final class PinHasher {
  static const pinLength = 4;

  static bool isValidPin(String pin) =>
      pin.length == pinLength && RegExp(r'^\d+$').hasMatch(pin);

  static String newSalt([Random? random]) {
    final rng = random ?? Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    return base64Url.encode(bytes);
  }

  static String hash(String pin, String salt) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();

  static bool verify(String pin, {required String salt, required String hash}) {
    final candidate = PinHasher.hash(pin, salt);
    if (candidate.length != hash.length) return false;
    var diff = 0;
    for (var i = 0; i < candidate.length; i++) {
      diff |= candidate.codeUnitAt(i) ^ hash.codeUnitAt(i);
    }
    return diff == 0;
  }
}
