import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/db/field_cipher.dart';

import '../../helpers/memory_secret_store.dart';

void main() {
  test('round-trips text, including Bangla', () async {
    final cipher = AesGcmFieldCipher(MemorySecretStore());
    for (final plain in ['1234567890123', '', 'রহিম উদ্দিন ১২৩৪', 'a' * 500]) {
      expect(await cipher.decrypt(await cipher.encrypt(plain)), plain);
    }
  });

  test('stored form is versioned and hides the plaintext', () async {
    final cipher = AesGcmFieldCipher(MemorySecretStore());
    final stored = await cipher.encrypt('1990123456789');
    expect(stored, startsWith('v1:'));
    expect(stored, isNot(contains('1990123456789')));
  });

  test('a fresh random nonce makes every ciphertext different', () async {
    final cipher = AesGcmFieldCipher(MemorySecretStore());
    expect(await cipher.encrypt('same'), isNot(await cipher.encrypt('same')));
  });

  test('the key is created once and reused by a new instance', () async {
    final secrets = MemorySecretStore();
    final stored = await AesGcmFieldCipher(secrets).encrypt('secret');
    expect(await AesGcmFieldCipher(secrets).decrypt(stored), 'secret');
    expect(secrets.values['khata_field_key_v1'], hasLength(64));
  });

  test('a different key cannot decrypt', () async {
    final stored = await AesGcmFieldCipher(MemorySecretStore())
        .encrypt('secret');
    await expectLater(
      AesGcmFieldCipher(MemorySecretStore()).decrypt(stored),
      throwsA(isA<SecretBoxAuthenticationError>()),
    );
  });

  test('tampering is detected', () async {
    final cipher = AesGcmFieldCipher(MemorySecretStore());
    final stored = await cipher.encrypt('secret value');
    final bytes = base64Url.decode(stored.substring(3));
    bytes[14] ^= 0x01; // flip a ciphertext bit
    final tampered = 'v1:${base64Url.encode(bytes)}';
    await expectLater(
      cipher.decrypt(tampered),
      throwsA(isA<SecretBoxAuthenticationError>()),
    );
  });

  test('unknown formats are rejected', () async {
    final cipher = AesGcmFieldCipher(MemorySecretStore());
    await expectLater(cipher.decrypt('plain text'), throwsFormatException);
    await expectLater(cipher.decrypt('v2:abcd'), throwsFormatException);
  });
}
