# Sprint 5 — Status and decisions

Companion to [sprint-implementation-plan.md](sprint-implementation-plan.md) (Sprint 5: day log, profit engine, dashboard).

## What was built

| ID | Result |
|---|---|
| S5-T1 | Day logs (`day_logs`): one per vehicle per day, enforced by the database. Adding income merges into the day's log; the assigned driver is linked automatically. |
| S5-T2 | **Today card** at the top of Home: income and profit today for a vehicle, quick amounts (+৳ 50 / 100 / 200 / 500), "Add income" on the on-screen keypad, an Undo for the last addition, and a switch between vehicles. Defaults to the vehicle you added first. |
| S5-T3 | **Close day** page: income, running costs, driver cost, vehicle costs and net profit for today, plus what is due to the driver (collect jama, salary building up, or pay from trips). |
| S5-T4 | **Gas / fuel** button opens the same expense editor as everywhere else (amount, quantity, odometer), so refuelling feeds the same fuel-efficiency report. |
| S5-T5 | **Profit engine** (pure Dart): gross income, running costs, driver cost, operating profit, vehicle costs, net profit; cash or accrual view; vehicle costs charged when paid or spread over the month (Settings → "Spread vehicle costs over the month"). Also profit per trip and per working day and the amount not yet received. |
| S5-T6 | **Daily rollups** (`daily_rollups`, local only): per vehicle per day totals kept up to date inside the same transaction as every trip, expense and day-log change. `RollupService.verify()` compares them with a fresh calculation and `rebuildAll()` repairs them. Databases upgraded from v4 are rolled up on first open. |
| S5-T7 | **Reports tab** dashboard: This month / This week (Saturday start) / Today, profit summary, vehicle ranking (best first). A year of five vehicles reports in well under 300 ms (benchmark test). |
| S5-T8 | Charts (`fl_chart`): profit trend, income vs costs, and an expense-mix donut. The donut's legend lists exact amounts and percentages, so the chart is never the only way to read a figure. |
| S5-T9 | Saving a trip or day log marks the driver present for that day if it was unmarked; an existing mark (absent, half day) is never changed. |
| S5-T10 | `seedDemoData` (a year, five vehicles, bulk inserts) used by the benchmark and by a "Generate demo data" tile in More, shown only in dev and staging builds. |
| S5-T11 | Tests, including the spec's CNG example: 2,800 income − gas 600 − other 100 = 2,100. |

## Rules worth knowing

- **Variable vs fixed costs:** everything on a trip, and everyday running costs bought for a vehicle (fuel, toll, parking, helper, police, food) are variable. Repairs, parts, tyres, service, washing, insurance, registration, loan instalments, "other" and custom categories bought for a vehicle are fixed.
- **Owner-borne only:** client-paid expenses and a driver's own non-reimbursable ones never reduce the owner's profit.
- **Cash vs accrual** follows the existing Settings → Profit view. Cash counts what was received; accrual counts fares when earned. Day-log income is always counted in full.
- **Amortizing** gives each day of a month an equal share of that month's fixed costs; the shares always add up exactly (no lost poisha).
- **Driver pay in reports:** stored trip pay, plus salary and daily-wage pay accruing by the day up to today (salary: the day's share of the month, less for absent/half days; daily wage: only marked days). Jama drivers accrue nothing; their rent is the jama module's (Sprint 8). Reports add salary day by day while payouts use the monthly calculation, so the two can differ by a few poisha.
- **Undo** takes the last addition off the day again (never below zero) and lasts 5 seconds.

## Changes to existing behaviour

- Bottom sheets (keypad, expense editor, pickers) now open above the whole app. Before, a snackbar could sit on top of a sheet's Done button.
- Home's list starts with the Today card, so vehicles are below it.
- Expenses carry a `spent_day` column (schema v5); existing rows are filled in from their time in the phone's timezone during the upgrade.

## Not done / limits

- Reports cover all vehicles or the ranking; there is no per-vehicle drill-down yet and no custom date range.
- Day logs have no screen for distance, hours or notes yet (the repository supports them).
- No history screen for past days; use the trip list and vehicle expenses.
- Charts and the Today card were only checked in widget tests, not on a device.
- Bangla strings are my translations and need native-speaker review.

## Checks run (on the development Mac)

- `flutter analyze`: no issues.
- `flutter test`: 547 tests pass (including the 3 golden-image tests; CI excludes those).
- Release APK (prod, split per ABI): arm64-v8a 26.8 MB, armeabi-v7a 24.4 MB, x86_64 28.5 MB. Under the 30 MB budget but the x86_64 build is close; each sprint adds about 0.6 MB.

## Testing notes

- A snackbar with an action stays up until dismissed unless `persist: false`; tests that tap a bottom button right after one must let it end first.
- Popup menus still open inside the app shell, so a snackbar can cover the bottom of one. Tests wait for it to go.
- The Today card pushes the vehicle list down, so list tests scroll to a tile before using it.
