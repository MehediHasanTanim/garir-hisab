# Sprint 3 — Status and decisions

Companion to [sprint-implementation-plan.md](sprint-implementation-plan.md) (Sprint 3: drivers, assignments, pay models).

## What was built

| ID | Result |
|---|---|
| S3-T1 | Schema v3 (`drivers`, `assignments`, `attendance_records`, `advances`, `payouts`, `payout_advance_allocations`) with a v2→v3 migration and a data-preservation test. **At most one active assignment per vehicle is enforced by the database**: a nullable `active_vehicle_key` column holds the vehicle id while the assignment runs (NULL once ended) and carries a unique constraint. |
| S3-T2 | Driver list (search by name, phone in any form, licence; Working / Left / All filters), add/edit form, detail page with Overview / Attendance / Advances / Payouts tabs. National ID is optional and **encrypted per field** (AES-256-GCM, key in the Keystore-backed store), never shown after saving; list rows only say a NID exists. Licence expiry is flagged. Reachable from More → Drivers. |
| S3-T3 | Per-vehicle "Driver & pay" page (from the vehicle menu on Home): current driver and terms, past drivers, assign / change / end. Switching ends the previous assignment the day before the new one starts; history is kept. |
| S3-T4 | `PayModel` sealed class (salary, daily wage, per trip, commission, jama, mixed) stored as **versioned JSON** (`v: 1`) with validation and a list of pay types allowed for each vehicle business model. |
| S3-T5 | Pay-model editor on the assignment form: type chips limited to what suits the vehicle, per-type fields, commission basis (before / after expenses), percentages entered as `12.5` and stored as basis points, jama frequency and off-days. |
| S3-T6 | Pure pay calculators with table-driven tests: salary pays each calendar month by its own length (so a full month is always exactly the monthly salary), daily wage, per trip, commission, mixed. |
| S3-T7 | Attendance: month calendar (week starts Saturday), tap a day to mark present / half day / absent / clear, running counts. |
| S3-T8 | Advances: give, list (recovered / remaining), delete while unrecovered. |
| S3-T9 | Payout screen and service: choose assignment and period (month stepper or custom dates), live preview of earned pay, bonus/penalty, advances recovered and net, record, void. Recording the same period twice returns the existing payout; overlapping periods are rejected. |
| S3-T10 | Audit log written in the same transaction as every change to vehicles, drivers, assignments, attendance, advances and payouts. Diffs list only changed fields; the NID is recorded as "changed" without its value. |
| S3-T11 | Tests for all of the above (see below). |

## Rules worth knowing

- **Salary attendance:** an unmarked day counts as worked; only days marked absent (lose the day) or half-day (lose half) reduce pay.
- **Daily wage attendance:** only days marked present or half-day are paid; unmarked means not worked.
- **Advance recovery:** oldest first, partially if needed, never more than the driver is owed. The net is never negative; any advance left over carries to the next payout.
- **Assignments:** a new assignment must start after the current one began, and may not overlap an earlier ended one. Pay types must suit the vehicle's business model; self-driven vehicles cannot have a driver. A driver who has left cannot be assigned.
- **Jama drivers** are not paid out; the rent is collected by the jama module (Sprint 8).
- **Payout period** is clipped to the days the assignment covers, and the screen says so.

## Not done / limits

- **Trip-based pay is zero for now.** Per-trip, commission and the commission part of mixed pay need trips, which arrive in Sprint 4. Those payouts show a note and cannot be recorded until there is something to pay (a bonus alone would allow it).
- Attendance is not yet filled in automatically from trips or day logs (planned with Sprint 4/5).
- A driver's running balance (earned − paid − advances over all time) is not shown; the Overview shows advances owed and the Payouts tab shows history.
- The driver photo and camera paths use the same fakes-only testing as vehicle photos; nothing was run on a device.
- Bangla strings are my translations and need native-speaker review.

## Checks run (on the development Mac)

- `flutter analyze`: no issues.
- `flutter test`: 336 tests pass (including the 3 golden-image tests; CI excludes those).
- Release APK (prod, split per ABI): arm64-v8a 25.6 MB, armeabi-v7a 23.0 MB. Under the 30 MB budget; about 0.8 MB more than Sprint 2.
- Nothing was run on a device or emulator.

## Testing note

Widget tests cannot `await stream.first` on a Drift query: Drift needs real timers, which the test's fake-async zone never runs, so the test hangs. Read streams in widget tests with `tester.runAsync` (see `_first` in `assignment_ui_test.dart`), or use the repositories' `Future` methods.
