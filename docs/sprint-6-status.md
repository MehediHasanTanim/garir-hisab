# Sprint 6 — Status and decisions

Companion to [sprint-implementation-plan.md](sprint-implementation-plan.md) (Sprint 6: sync, backup and reports).

**Read this first:** the app side is built and tested against an in-memory stand-in for the server. The server SQL (schema, RLS, `sync_push`, `sync_pull`) and its pgTAP tests are written but **have never been run** (no Supabase CLI or database was available here). Nothing was tried against a real Supabase project or on a device. Treat the first run against a real project as the real test.

## What was built

| ID | Result |
|---|---|
| S6-T1 | Server mirror schema, **generated from the Drift snapshot** (`backend/tools/gen_sync_schema.py`, output in `migrations/20261024000000_sync_schema.sql`) so the two cannot drift apart by hand. Each synced table gets `owner_id` (defaults to the signed-in user), `server_seq` (from one sequence, stamped by trigger on every insert/update), row-level security (select/insert/update only your own rows), an `(owner_id, server_seq)` index, and the same unique keys as the phone. No foreign keys on the server, so rows may arrive in any order. |
| S6-T2 | **Outbox = the existing `dirty` flag.** Every repository write already bumps `rev` / `updated_at` and sets `dirty` in the same transaction. A new test (`write_through_test.dart`) runs about 27 repository operations against a clean database and checks that every row that changed is dirty again. |
| S6-T3 | `sync_push(rows)`: batch of up to 500, owner forced to the caller, per-row result `accepted` / `conflict` (server copy is newer, returned) / `rejected` (reason). Idempotent: same row again is accepted. A stamp more than a day ahead is pulled back to a day ahead. |
| S6-T4 | `sync_pull(since, lim)`: rows changed after the cursor, oldest first, page of up to 1000, with `cursor` and `has_more`. Deleted rows are ordinary rows with `deleted_at` set. |
| S6-T5 | **Sync engine** (`lib/core/sync/`): pushes 200 rows per batch, parents before children; pulls pages; one run at a time (concurrent calls share it); exponential backoff 5 s → 15 min with ±20% jitter; states: not signed in, syncing, up to date, offline, signed out, other account, error. Runs on a 2 s debounce after local changes, every 5 minutes, and when sign-in changes. |
| S6-T6 | **Poison rows:** a row the server rejects is recorded in `sync_issues`, does not block others, and after 5 failed attempts is set aside until "Try again" is tapped. A row that cannot be stored on pull is recorded and skipped the same way. |
| S6-T7 | **Conflicts, v1: last write wins per row by `updated_at`.** Locally, an unsent edit that is newer than the server's copy is kept and goes up on the next push; otherwise the server's copy replaces ours. A push is only marked done if the row was not edited again meanwhile (`rev` guard). |
| S6-T8 | **Restore on a new phone:** sign in, open More → Sync & backup → Restore (or just sign in on an empty phone; the first sync pulls everything). Daily rollups are rebuilt after a pull and match the original phone's. |
| S6-T9 | **Sync & backup** page (More): plain-language status, last backed up time, how many changes are waiting, "Needs attention" with Try again, Sync now, Restore (asks first). English and Bangla. Hidden in builds without a backend. |
| S6-T10 | Fault-injection server for tests (`MemorySyncServer`): fail the next call, lose the reply after storing, reject chosen ids. Tests cover lost acknowledgements (no duplicates), network failure then recovery, expired session, parked rows, two phones editing offline, tombstones, paging, wrong account. |
| S6-T11 | Schema v6: `sync_meta` (cursor, owner, last sync) and `sync_issues`, both local only. The migration marks every existing row dirty so data from before sync reaches the server. |

## Rules worth knowing

- **Which tables sync:** vehicles, drivers, assignments, attendance, advances, payouts, payout allocations, expense categories, trips, expenses, day logs. **Not synced:** audit log, daily rollups (rebuilt after a pull), sync bookkeeping.
- **Owner:** the server always sets the owner to the caller. A phone remembers the first account that synced; a different account on the same phone is refused ("holds data from another account") rather than mixed in.
- **Local-only mode** (no `SUPABASE_URL` / `SUPABASE_ANON_KEY`, or signed out) is unchanged: no sync, no sync menu entry.
- **Clock:** only a clock running *ahead* is corrected (a day ahead at most, on both phone and server). A clock far *behind* will lose conflicts; there is no fix for that without a server clock.
- **National ID:** synced in its encrypted form only; the server never sees it in the clear.
- **Server setup:** apply the two new migrations (`supabase db push`), then build with the two `--dart-define`s.

## Not done / limits

- **Server SQL and pgTAP never executed.** Expect to fix small things on first run. `supabase test db` runs `tests/database/sync_test.sql` (16 checks).
- **Not on a real server or device.** The Supabase transport (`supabase_sync_server.dart`) is thin and untested; only its parsing and error mapping were written to the server's contract.
- **Receipt and photo files do not sync**, only their file names. Needs object storage and an upload queue (planned T-item left open).
- **No PDF reports.** The Bangla-shaping spike (S0-T5) is still unresolved because the font was never added, so PDF templates were not started.
- **No new report screens** beyond Sprint 5's dashboard.
- **No background sync** when the app is closed (no WorkManager). Sync runs while the app is open.
- **Unique-key clashes:** if two phones create the same attendance day or payout period offline with different ids, the second one cannot be stored on pull; it appears under "Needs attention" instead of being merged.
- **Row-level conflicts:** two phones editing different fields of the same row offline lose one edit (whole row, later wins). Field-level merge is not built.
- Bangla strings are my translations and need native-speaker review.

## Checks run (on the development Mac)

- `flutter analyze`: no issues.
- `flutter test`: 590 tests pass (43 more than Sprint 5), including the 3 golden-image tests (CI excludes those). New: engine and fault tests, the write-through check, the v5→v6 migration, and the sync page UI (including 200% text and Bangla).
- Release APK (prod, split per ABI): arm64-v8a 26.9 MB, armeabi-v7a 24.5 MB, x86_64 28.6 MB. Under the 30 MB budget; x86_64 is the closest.

## Testing notes

- The sync engine owns timers (periodic sync, retry). Flutter checks for pending timers before tear-downs run, so UI tests that start it must unmount and dispose the container inside the test (`_end` in `sync_ui_test.dart`).
- The engine only exists when `syncServerProvider` is overridden, so all earlier tests run unchanged.
