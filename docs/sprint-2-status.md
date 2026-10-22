# Sprint 2 — Status and decisions

Companion to [sprint-implementation-plan.md](sprint-implementation-plan.md) (Sprint 2: auth, onboarding, vehicles).

## What was built

| ID | Result |
|---|---|
| S2-T1 | `profiles` table, RLS policies, auto-create trigger (`backend/supabase/migrations/20261022010000_profiles.sql`) and a pgTAP test (`backend/supabase/tests/database/profiles_rls.test.sql`). **The pgTAP test has not been run** (needs the Supabase CLI and a database). |
| S2-T2 | Phone entry (Bangladesh numbers, Bangla digits accepted), 6-digit code entry with auto-submit, 60 s resend cooldown, localized error messages for rate limit / bad code / no network. Android autofill hint `oneTimeCode` is set; the SMS Retriever API is **not** integrated. |
| S2-T3 | `AuthRepository` with a Supabase implementation (Supabase persists the session on device, so cold start works offline), a fake for tests, and a local-only implementation. |
| S2-T4 | Decision implemented: signing in is optional ("Continue without account"); it can be done later from More → Account. Without `SUPABASE_URL` / `SUPABASE_ANON_KEY` the app runs local-only. |
| S2-T5 | Onboarding: language → account → role → first vehicle → business model. Progress is saved after every step, so it resumes after the app is killed. The Driver role is shown as "Coming soon" (driver app is planned for v1.2). |
| S2-T6 | Schema v2 adds `vehicles`; migration v1→v2 with a data-preservation test; vehicle domain, repository. |
| S2-T7 | Home shows the vehicle list: search (name, model, registration number), status chips, "Show archived", loads more as you scroll. |
| S2-T8 | Add/edit form with photo (camera/gallery, resized to 1280 px at quality 70 by the picker), duplicate registration warning, optional model/year/purchase date/price. |
| S2-T9 | Archive/restore (hidden by default, kept for reports) and status change (Active / In garage / Sold). |
| S2-T10 | 4-digit PIN lock (salted SHA-256 in the Keystore-backed store), optional biometrics, lock timeout (immediately / 30 s / 1 / 5 min), 5 wrong PINs block for 30 s, change / turn off require the current PIN. |
| S2-T11 | Domain, repository, controller and widget tests for all of the above. |

## Decisions worth knowing

- **Registration numbers** are compared by a normalized key (case, spaces, hyphens ignored, Bangla digits converted). Combining marks are kept so Bangla plates like `ঢাকা` match correctly.
- **Duplicate registration is a warning, not an error**: two vehicles may legitimately share a number during a handover.
- **Router refreshes only on gate changes** (onboarding done, locked). Refreshing on every settings change rebuilt the current page and reset PIN entry mid-flow.
- **Photos** are stored by file name; the database never holds an absolute path.
- **Version bump**: Supabase publishable (anon) key is read from the `SUPABASE_ANON_KEY` define and passed as `publishableKey`.

## Checks run (on the development Mac)

- `flutter analyze`: no issues.
- `flutter test`: 149 tests pass (including 3 golden-image tests; CI excludes those).
- Release APK (prod, split per ABI): arm64-v8a 24.8 MB, armeabi-v7a 22.2 MB, x86_64 26.4 MB. Under the 30 MB budget but it grew about 6 MB over Sprint 0 (Supabase, biometrics, image picker); keep an eye on it.

## Not verified / not done

- Nothing was run on a device or emulator. Camera, gallery, biometrics, and the Keystore-backed secret storage are exercised only through fakes in tests.
- No real SMS was sent (S0-T6 OTP spike is still pending), so the OTP screens have only been tested against a fake backend.
- pgTAP RLS test not run.
- SMS Retriever autofill not implemented.
- Vehicle list "pagination" grows a `LIMIT` as you scroll (simple and reactive); it is not keyset pagination.
- Bangla strings are my translations and need native-speaker review.
