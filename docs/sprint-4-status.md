# Sprint 4 — Status and decisions

Companion to [sprint-implementation-plan.md](sprint-implementation-plan.md) (Sprint 4: trips and expenses).

## What was built

| ID | Result |
|---|---|
| S4-T1 | Expense categories: 15 built-in (fuel/CNG gas, toll, parking, helper, police, driver food, repair, parts, tyre, service, washing, insurance, registration, loan, other) with Bangla and English names, plus your own. Built-in ones have fixed ids (`default:<key>`) so devices will not duplicate them when sync arrives. Categories are archived, never deleted, so old expenses keep their label. More → Expense categories to add, rename (custom only) and archive. |
| S4-T2 | Schema v4 (`expense_categories`, `trips`, `expenses`) with indexes on vehicle+time and trip, migration, repositories. Every change is audited in the same transaction. |
| S4-T3 | Quick add: Entries → Add trip → fare on the on-screen keypad → expense chip + amount → Save. **A trip with a fare and one expense takes 6 taps, not counting the digits** (tested). Vehicle defaults to the last one used; driver to whoever is assigned. |
| S4-T4 | Expense chips (Fuel, Toll, Parking, Helper) and a More list with every category; tap a row to edit paid-by, reimbursable, fuel quantity and odometer, note, receipt. New categories can be created from the editor. |
| S4-T5 | Live profit card: fare − expenses the owner bears − driver pay. |
| S4-T6 | Payment: paid / partly paid / unpaid with the amount received (never more than the fare). "Record payment" on the trip adds later payments up to what is due. |
| S4-T7 | Driver pay per trip is calculated from the assigned driver's terms (per trip; commission before or after expenses; the commission part of mixed pay). It can be overridden and reset; an override is flagged. Editing an old trip keeps its stored pay until something that affects it changes. |
| S4-T8 | From/To suggest places from earlier trips, most used first. |
| S4-T9 | Repeat trip (opens a pre-filled new trip) and return leg (route swapped, linked to the outbound trip). |
| S4-T10 | Trip list on the Entries tab grouped by day with route, vehicle, driver, fare, profit and payment label; filters for payment status, vehicle and period (all time, today, this month, last month). Trip detail, edit, delete (soft). |
| S4-T11 | Vehicle expenses (repairs, service, insurance…) from the vehicle menu on Home. |
| S4-T12 | Receipt photos on expenses. A photo that is dropped or replaced is deleted when the trip or expense is saved, and one picked but never saved is deleted when you leave. |
| S4-T13 | Fuel entries take quantity and odometer; the vehicle expenses page shows average km per litre/m³ and fuel cost per km (full-tank method, needs two fills). |
| S4-T14 | Tests (see below). |

## Payouts now use trips (Sprint 3 follow-up)

Per-trip, commission and mixed pay in a payout is the sum of the driver pay stored on each trip in the period (for that driver and vehicle), so owner overrides are honoured. Salary and daily wage are unchanged. Trip-based payouts that were blocked in Sprint 3 can now be recorded.

## Rules worth knowing

- **Who bears an expense:** the owner's own, and a driver-paid expense marked reimbursable. A client-paid expense, or a driver's own non-reimbursable one, does not reduce the owner's profit. Only driver-paid expenses can be reimbursable.
- **Trip day** is the local calendar day of the trip's start time.
- A trip needs a positive fare; received is between 0 and the fare.
- Deleting a trip soft-deletes its expenses too.

## Bugs found and fixed during this sprint

- Place suggestions returned the lower-case spelling when the same place was typed two ways.
- The trip form and the category dialog used app state or a text controller after they were closed.
- The Entries trip tile and the payment card on the trip detail overflowed at 200% text size.

## Not done / limits

- Day logs (CNG daily income) and automatic attendance from trips come in Sprint 5.
- The trip list shows profit per trip but no day or month totals yet (dashboard, Sprint 5).
- Distance is typed by hand; it is not taken from odometer readings.
- Clients and saved routes come in Sprint 11, so there is no customer field yet.
- Receipts, camera and gallery are tested through fakes only. Nothing was run on a device or emulator.
- Bangla strings are my translations and need native-speaker review.

## Checks run (on the development Mac)

- `flutter analyze`: no issues.
- `flutter test`: 452 tests pass (including the 3 golden-image tests; CI excludes those).
- Release APK (prod, split per ABI): arm64-v8a 26.2 MB, armeabi-v7a 23.8 MB, x86_64 27.9 MB. Under the 30 MB budget, about 0.6 MB more than Sprint 3.

## Testing notes

- Widget tests that end on a screen watching Drift queries need Drift's cleanup timer flushed; `pumpApp` now registers a teardown that unmounts the tree and pumps.
- Filter chips and tab bars scroll sideways, so tests scroll to a chip before tapping it.
- Expense rows share their label with the quick chips, so tests target the row (`ListTile`) explicitly.
