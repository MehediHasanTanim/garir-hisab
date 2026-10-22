import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/spikes/encrypted_db.dart';

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('khata_spike'));
  tearDown(() => dir.deleteSync(recursive: true));

  test('encrypted DB: 50k rows insert and count', () async {
    final result = await runEncryptedDbSpike(
      File('${dir.path}/enc.db'),
      key: 'test-key',
    );
    // ignore: avoid_print, spike output is the deliverable
    print('SPIKE S0-T4 (host): $result');
    expect(result.rows, 50000);
  });

  test(
    'encrypted DB file does not contain plaintext and rejects wrong key',
    () async {
      final file = File('${dir.path}/enc2.db');
      await runEncryptedDbSpike(file, key: 'right-key', rows: 100);
      final bytes = file.readAsBytesSync();
      expect(String.fromCharCodes(bytes).contains('row 5'), isFalse);
      expect(
        String.fromCharCodes(bytes.take(15)).contains('SQLite format'),
        isFalse,
      );
      await expectLater(
        runEncryptedDbSpike(file, key: 'wrong-key', rows: 1),
        throwsA(anything),
      );
    },
  );
}
