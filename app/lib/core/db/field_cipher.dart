import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:vehicle_khata/core/db/database_key_store.dart';

/// Field-level encryption for especially sensitive values (e.g. national ID),
/// on top of the encrypted database file. Values stay encrypted when synced.
abstract interface class FieldCipher {
  Future<String> encrypt(String plain);
  Future<String> decrypt(String stored);
}

/// AES-256-GCM. Stored form: `v1:` + base64url(nonce ‖ ciphertext ‖ mac).
class AesGcmFieldCipher implements FieldCipher {
  new(this._secrets);

  static const _keyName = 'khata_field_key_v1';
  static const _prefix = 'v1:';

  final SecretStore _secrets;
  final _algorithm = AesGcm.with256bits();
  SecretKey? _key;

  Future<SecretKey> _loadKey() async {
    final cached = _key;
    if (cached != null) return cached;
    var hex = await _secrets.read(_keyName);
    if (hex == null || hex.length != 64) {
      final key = await _algorithm.newSecretKey();
      final bytes = await key.extractBytes();
      hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      await _secrets.write(_keyName, hex);
    }
    final bytes = [
      for (var i = 0; i < 64; i += 2)
        int.parse(hex.substring(i, i + 2), radix: 16),
    ];
    return _key = SecretKey(bytes);
  }

  @override
  Future<String> encrypt(String plain) async {
    final box = await _algorithm.encrypt(
      utf8.encode(plain),
      secretKey: await _loadKey(),
    );
    return _prefix + base64Url.encode(box.concatenation());
  }

  /// Throws [FormatException] for malformed input and [SecretBoxAuthenticationError]
  /// when the data was tampered with or the key differs.
  @override
  Future<String> decrypt(String stored) async {
    if (!stored.startsWith(_prefix)) {
      throw const FormatException('unknown encrypted field format');
    }
    final bytes = base64Url.decode(stored.substring(_prefix.length));
    final box = SecretBox.fromConcatenation(
      bytes,
      nonceLength: _algorithm.nonceLength,
      macLength: _algorithm.macAlgorithm.macLength,
    );
    final clear = await _algorithm.decrypt(box, secretKey: await _loadKey());
    return utf8.decode(clear);
  }
}
