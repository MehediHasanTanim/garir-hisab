# Vehicle Khata

Trip and income ledger for CNG, pickup, truck and rented-rickshaw ("jama") owners.

| Path | Contents |
|---|---|
| `app/` | Flutter mobile app (Android first) |
| `backend/` | Supabase migrations and edge functions |
| `docs/` | Feature spec, technical design, sprint plan, ADRs, spike reports |

## Getting started

```bash
cd app
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter run --flavor dev -t lib/main_dev.dart
```

Flavors: `dev`, `staging`, `prod` (Android application IDs
`com.vehiclekhata.vehicle_khata[.dev|.staging]`). Pass
`--dart-define=SENTRY_DSN=...` to enable Sentry.

## Quality gates

```bash
cd app && dart format --set-exit-if-changed lib test && flutter analyze && flutter test --exclude-tags golden
```
CI additionally builds a release APK and fails if it exceeds 30 MB.

## Golden tests

```bash
cd app && flutter test --tags golden [--update-goldens]
```
Goldens are excluded from CI because rendering differs across OSes.
