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
dart run build_runner build --delete-conflicting-outputs
flutter run --flavor dev -t lib/main_dev.dart
```

Flavors: `dev`, `staging`, `prod` (Android application IDs
`com.vehiclekhata.vehicle_khata[.dev|.staging]`). Pass
`--dart-define=SENTRY_DSN=...` to enable Sentry.

## Quality gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
```
CI additionally builds a release APK and fails if it exceeds 30 MB.
