# Sprint 9 — Status and decisions

Companion to [sprint-implementation-plan.md](sprint-implementation-plan.md) (Sprint 9: ledger, dues and payments, spec F10).

## The main design decision (please read)

The plan asked for the ledger to be the place where accruals are posted, with trips, jama and payouts migrated to post into it (S9-T2). That would have meant rewriting every repository. Instead the ledger is a **derived, append-only journal**:

- What people owe is still held by the records that exist (jama days, advances, trips, reimbursable expenses).
- `LedgerService.post()` compares each record's outstanding amount with what the ledger holds and **appends a row for any difference**. It never updates or deletes. A fare that is paid in two parts leaves three rows: +1,000 (accrual), −300 (adjust), −700 (reversal). The first row is never touched.
- Row ids are deterministic (`lg:<type>:<record id>:<n>`), so two phones that post the same change write the same row and sync stays idempotent.
- Posting runs whenever the Dues screens read, and after each payment. It is not triggered on every write elsewhere, so the ledger can lag behind until one of those happens. `reconcile()` shows any gap.

## What was built

| ID | Result |
|---|---|
| S9-T1 | Schema v8: `ledger_entries`, `ledger_payments`, `ledger_allocations`. Append-only by convention on the phone (code never updates them) and by rule on the server. A payment is undone by appending an opposite payment (`reverses_id`), not by editing. |
| S9-T2 | **Partly, by the derived design above.** Jama days, advances, unpaid fares and reimbursable expenses all post to the ledger. No data was moved; the first `post()` on an existing database back-fills everything. The reconciliation check below is the verification total. |
| S9-T3 | Party balances and ageing (0–7, 8–30, over 30 days) from the open items. |
| S9-T4 | **Dues** screen (More): everyone with a balance, "owes you" or "you owe". Party page with balance, ageing, open items, and a text statement. |
| S9-T5 | **Record payment:** "Receive payment" / "Pay them" with the on-screen keypad. Applied oldest-first. The service also accepts a manual allocation (tested), **but there is no screen for choosing it yet.** The payment updates the real record: trips get their received amount raised, jama is collected, reimbursed expenses are marked paid in the ledger. |
| S9-T6 | Driver-paid, reimbursable expenses are a **payable to the driver** (shown as "you owe"). The driver is the trip's driver, or the one assigned to the vehicle that day. Paying them clears it; the payment can be reversed. |
| S9-T7 | Reminder text in Bangla and English (follows the app language), opened in the system share sheet so it can go by WhatsApp or SMS. There is no direct SMS/WhatsApp intent. |
| S9-T8 | Statement shared as **text** only (no PDF or image). |
| S9-T9 | Server: `20261026000000_sync_ledger.sql` adds the three tables with a trigger that refuses any change or delete and silently ignores an identical re-push. pgTAP file `ledger_test.sql`. |
| S9-T10 | `LedgerService.reconcile()`: each record's ledger total equals its outstanding amount; unpaid fares in the ledger equal the daily rollups (fare − received); every payment's allocations add up to the payment. Returns a list of problems, writes nothing. |
| S9-T11 | Tests: ageing edges and totals; posting kinds; append-only behaviour and deterministic ids; deleting a trip reverses its debt; jama and advances per driver; reimbursable expenses, payment and reversal; oldest-first and manual allocation; refused payments; a reconcile that catches a stray row; a property test of random payments against ledger, trips and rollups; v7→v8 migration; Dues screens (list, ageing, payment, over-payment, reminder, statement, 200% text, Bangla). |

## Not done / limits

- **Reconciliation is a function, not a nightly job.** It runs in tests; there is no debug screen or scheduled run.
- **Advances cannot be repaid directly.** They are recovered through payouts, as before; the Dues screen says so. Advances still count in a driver's balance.
- **Manual allocation has no screen**; payments go oldest-first.
- **Jama allocation is per assignment, oldest first**, not to a chosen day.
- **Unnamed customers only:** trips have no customer field yet (clients arrive in Sprint 11), so all unpaid fares group under "Customers (no name)".
- Money received can only be undone through its own record (e.g. cancel the jama payment); only payments *to* a party can be reversed in the ledger.
- Statement is text, not PDF.
- The server SQL (this migration, the earlier sync migrations, and all pgTAP files) has never been run.
- Nothing was run on a device. Bangla strings are my translations and need native-speaker review.

## Fixed along the way (Sprint 8 follow-up)

Generated migration tests stop at an older schema while the app class is the newest, which made the rollup rebuild query jama tables that did not exist yet. The rollup service now checks that the jama table exists before reading it.
