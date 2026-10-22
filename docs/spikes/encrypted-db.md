# Spike S0-T4: Drift + encrypted SQLite

**Code:** `app/lib/spikes/encrypted_db.dart`, `app/test/encrypted_db_spike_test.dart`

## Approach
sqlite3 3.x ships through build hooks; `app/pubspec.yaml` selects
`source: sqlite3mc` (SQLite3 Multiple Ciphers). The key is applied with
`PRAGMA key` as the first statement on each connection.

## Results

| Environment | Open | Insert 50k rows | Count |
|---|---|---|---|
| macOS host (test run, 2026-10-22) | 638 ms | 553 ms | 24 ms |
| Android 8, 2 GB device | **not measured** | | |

Host tests also confirm: file has no `SQLite format` header, plaintext rows are
not visible in the bytes, and a wrong key fails to open.

## APK size (prod release, split per ABI, includes sqlite3mc, Sentry, pdf, Drift)
arm64-v8a 19.0 MB, armeabi-v7a 15.8 MB, x86_64 20.5 MB — all under the 30 MB budget. Delta vs. a build without the hook was not measured.

## To finish on a device
1. Run the spike (call `runEncryptedDbSpike`) on an Android 8 / 2 GB device and fill in the table above.

## Decision
**Provisional GO** on host evidence. Final go/no-go needs the device run above. Fallback: OS-level encryption plus Keystore-wrapped export (technical design §17).
