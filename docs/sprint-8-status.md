# Sprint 8 — Status and decisions

Companion to [sprint-implementation-plan.md](sprint-implementation-plan.md) (Sprint 8: jama module, spec F7).

## What was built

| ID | Result |
|---|---|
| S8-T1 | Schema v7: `jama_entries` (unique per assignment and due day), `jama_payments`, `jama_allocations`, `jama_deposits`, `jama_pauses`, all synced (server mirror in `20261025000000_sync_jama.sql`, generated from the v7 snapshot). Jama amount, frequency and off-days already live in the pay model (`JamaPay`). |
| S8-T2 | **Idempotent generator** (`JamaRepository.generate`): creates every missing entry from the assignment start up to today (or the assignment end), skipping off-days; running it again creates nothing; it backfills days missed while the app was closed. Runs when the app opens (shell) and when the Jama page opens. |
| S8-T4 | **Collect** on the Jama page (Home ⋮ menu on jama vehicles): one tap collects the usual amount (or what is left, if less), "Other amount" uses the on-screen keypad. A snackbar offers Undo. Over-collecting is refused. |
| S8-T5 | **Calendar** by month (week starts Saturday): green paid, yellow partly paid, red not paid, blue-grey waived, grey no jama. Each day also has a text label for screen readers. Tapping a day shows what was paid and owed. |
| S8-T6 | **Baki and settlement:** a payment is applied to the oldest unpaid days first and never to more than a day owes; it never exceeds the total owed. What is paid is the sum of allocations, so a payment never edits an entry. Payments can be cancelled (days become owed again). Property test: allocations never exceed the payment or any day's balance, and always go oldest first. |
| S8-T7 | **Garage:** mark the vehicle off the road from today. "Pause" = no jama due (unpaid days are removed, days with money paid keep it); "Waive" = jama still counted but forgiven. Applies to existing and future days; "Back on the road" ends it. |
| S8-T8 | **Deposit:** received, refunded or deducted; refunds cannot exceed what is held. |
| S8-T9 | **Owner profit for jama vehicles:** jama collected counts as income on the day it is handed over (it feeds the same daily totals as day-log income); owner-borne costs come off as before. Test for the spec example: ৳600 × 26 days = ৳15,600, minus repairs ৳2,400 and loan ৳5,000 = **৳8,200**. |
| S8-T10 | **Jama report** (More): per month, expected, collected, owed, collection rate %, and who is behind (days missed, since when), biggest first. Waived and paused days are not counted as expected. |
| S8-T11 | Tests: generator (Fridays off, 26 days in April, start mid-month, month/year/leap-day boundaries, weekly, finished and re-assigned assignments, future start), collecting, void, waive, garage modes, deposit, report, the ৳8,200 example, write-through (every jama write marks rows to sync), v6→v7 migration, and the Jama page (one-tap collect and undo, calendar colours, waive, garage, 200% text, Bangla). |

## Rules worth knowing

- **Weekly jama** falls due on the weekday of the start date; off-days do not apply to it.
- **Collecting** only applies to days up to today; future days cannot be paid in advance.
- **A new driver** (re-assignment) starts a new schedule from their start date; the previous driver's baki stays with them.
- Income is counted when jama is **handed over**, not when it falls due.

## Not done / limits

- **S8-T3 server fallback generator (P1) was not built.** Entries are only created by the app. If an owner never opens the app, nothing is generated until they do (then it backfills).
- **No background generation (WorkManager)**, so there is no evening reminder notification either.
- **Cost split** (who pays fuel/repairs for a jama vehicle) is not a separate setting: use the existing "paid by" on each expense.
- A pause or waive always starts from today; there is no date picker, and past dates cannot be set from the screen (the repository supports any range).
- No lump-sum "settle baki" screen beyond Other amount, which already applies oldest-first.
- Nothing was run on a device. Bangla strings are my translations and need native-speaker review.
- The Sprint 6 server SQL, including this sprint's new migration, has never been run.
