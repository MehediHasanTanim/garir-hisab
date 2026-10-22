import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Minimal secret storage so the key logic can be tested without Keystore.
abstract interface class SecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class KeystoreSecretStore implements SecretStore {
  const new([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}

/// Generates the database key on first run and persists it in secure storage.
class DatabaseKeyStore {
  new(this._store, {Random? random}) : _random = random ?? Random.secure();

  static const _keyName = 'khata_db_key_v1';

  final SecretStore _store;
  final Random _random;

  Future<String> getOrCreateKey() async {
    final existing = await _store.read(_keyName);
    if (existing != null && existing.isNotEmpty) return existing;
    final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
    final key = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    await _store.write(_keyName, key);
    return key;
  }
}
