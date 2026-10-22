# Vehicle Khata — Technical Design

> Companion to [feature-spec.md](feature-spec.md). Describes architecture, data design, sync, and engineering practices for the MVP (v1.0) and the path to v2.0.

- **Status:** Draft v0.1
- **Scope:** Mobile app (Flutter, Android first), backend, sync, reports, security, CI/CD

---

## 1. Goals & Constraints

| Constraint | Implication |
|---|---|
| Low-end Android (2 GB RAM, Android 8+), patchy data | Offline-first, small APK (< 30 MB), cheap rendering, delta sync |
| Money data, low trust | Integer money math, audit log, encrypted local DB, simple backup/restore |
| Bangla-first | Full i18n, Bangla numerals, Bengali PDF fonts, correct text shaping |
| Solo / small team | Managed backend, minimal moving parts, one codebase |
| Many small writes, few reads | Local SQLite is the source of truth; server is a replica + backup |

**Design principle:** *the phone is the primary database; the cloud is sync and backup.*

---

## 2. High-Level Architecture

```
┌──────────────────────────── Flutter App ────────────────────────────┐
│  UI (Material 3, Bangla/EN)                                          │
│   └─ State: Riverpod  ──►  Use cases (domain)  ──►  Repositories     │
│                                                       │              │
│                                  ┌────────────────────┴───────────┐  │
│                                  │ Drift (SQLite, SQLCipher)      │  │
│                                  │  + outbox table (pending ops)  │  │
│                                  └────────────────────┬───────────┘  │
│  Sync engine (WorkManager / foreground) ◄─────────────┘              │
│  Local notifications · PDF/Excel generator · Image compressor        │
└───────────────────────────────┬──────────────────────────────────────┘
                                │ HTTPS (JWT)
┌───────────────────────────────▼──────────────────────────────────────┐
│ Backend (Supabase: Postgres + Auth + Storage + Edge Functions)       │
│  • Phone OTP auth      • Row-Level Security per owner                │
│  • /sync/push, /sync/pull (RPC)   • Receipt/document storage         │
│  • Scheduled jobs (backup export, jama row generation fallback)      │
│  • SMS gateway (SSL Wireless / BulkSMSBD) via Edge Function          │
└──────────────────────────────────────────────────────────────────────┘
```

### Why these choices
| Decision | Rationale | Alternative considered |
|---|---|---|
| Flutter | One codebase, smooth on low-end devices, strong custom-font support | React Native (larger runtime, more native glue) |
| Drift + SQLite | Typed queries, migrations, streams for reactive UI | Isar/Hive (weaker relational queries/reports) |
| SQLCipher | Encrypted at rest for financial data | Plain SQLite (rejected: privacy) |
| Supabase | Postgres + RLS + auth + storage with little ops | Firebase (weaker SQL reporting, vendor-lock), custom Node (more ops) |
| Riverpod | Testable, compile-safe DI + state | Bloc (more boilerplate) |

---

## 3. App Architecture (Clean, feature-first)

```
lib/
  main.dart
  app/                 # router, theme, DI bootstrap, l10n
  core/
    money/             # Money value type, formatters
    db/                # Drift database, migrations, DAOs
    sync/              # outbox, push/pull, conflict logic
    auth/  notifications/  pdf/  export/  utils/
  features/
    vehicles/   drivers/   trips/   daylog/   expenses/
    jama/       dues/      reports/ maintenance/
    clients/    settings/  onboarding/
      ├─ data/         # DAOs, repositories, DTO mappers
      ├─ domain/       # entities, use cases, pure logic
      └─ presentation/ # screens, widgets, providers
```

Rules:
- `domain/` has **no Flutter or DB imports** → pure Dart, fast unit tests.
- All profit/ledger math lives in `core/` or `domain/` (never in widgets or SQL strings scattered around).
- Navigation: `go_router`, with deep links for notification taps.

---

## 4. Money Handling

- Stored as **`INTEGER` poisha** (1 ৳ = 100 poisha). No floats anywhere in persistence or calculations.
- `Money` value class: `int minor`, add/sub/compare, `percentOf(basisPoints)` using integer arithmetic with banker's rounding documented and tested.
- Commission percentages stored as basis points (20% = 2000).
- Formatting layer: Bangla/Latin numerals, `৳ 1,23,456` (lakh/crore grouping) vs. `123,456`.
- Fuel quantity stored as integer milli-units (litre ×1000, m³ ×1000).

---

## 5. Local Database Design

### 5.1 Conventions (all synced tables)
| Column | Type | Purpose |
|---|---|---|
| `id` | TEXT (UUIDv7) | Client-generated; time-ordered, safe offline |
| `owner_id` | TEXT | Tenant key (RLS on server) |
| `created_at`, `updated_at` | INTEGER (epoch ms, UTC) | Ordering/sync |
| `deleted_at` | INTEGER NULL | Soft delete (tombstone) |
| `rev` | INTEGER | Local monotonic revision for conflict detection |
| `dirty` | INTEGER | 1 = has unsynced change (also tracked in outbox) |

### 5.2 Core tables (summary)
```
vehicle(id, nickname, type, reg_no, fuel_type, business_model, status, photo_path, ...)
driver(id, name, phone, license_no, license_expiry, status, ...)
assignment(id, vehicle_id, driver_id, pay_model, pay_params_json, start_date, end_date)
trip(id, vehicle_id, driver_id, client_id, route_id, started_at, from_place, to_place,
     distance_m, fare_minor, received_minor, driver_pay_minor, note, status)
day_log(id, vehicle_id, driver_id, log_date, collection_minor, distance_m, hours_min, note)
expense(id, vehicle_id, trip_id, day_log_id, category_id, amount_minor, paid_by,
        reimbursable, spent_at, qty_milli, odometer_m, receipt_path)
expense_category(id, name_bn, name_en, kind, is_default, archived)
jama_entry(id, assignment_id, due_date, expected_minor, paid_minor, status, waived_reason)
ledger_entry(id, party_type, party_id, direction, amount_minor, ref_type, ref_id, at, note)
payment(id, party_type, party_id, amount_minor, method_label, paid_at)
payment_allocation(id, payment_id, ledger_entry_id, amount_minor)
attendance(id, driver_id, day, status)
advance(id, driver_id, amount_minor, given_at, payout_id)
payout(id, driver_id, period_start, period_end, gross_minor, deductions_minor, net_minor, paid_at)
client(id, name, phone, address)
route(id, from_place, to_place, distance_m, default_fare_minor, default_toll_minor)
document(id, subject_type, subject_id, doc_type, number, expiry, image_path)
service_reminder(id, vehicle_id, type, due_km, due_date, last_done)
audit_log(id, entity, entity_id, action, diff_json, at)         -- local + synced
-- local-only:
outbox(seq, entity, entity_id, op, payload_json, created_at, attempts)
sync_state(key, value)                                          -- cursors, last_sync
```

### 5.3 Indexes (hot paths)
- `trip(vehicle_id, started_at DESC)`, `day_log(vehicle_id, log_date)`, `expense(vehicle_id, spent_at)`
- `jama_entry(assignment_id, due_date)` unique, `ledger_entry(party_type, party_id, at)`
- Partial indexes on `deleted_at IS NULL` for list queries.

### 5.4 Ledger model
Dues are **derived from an append-only ledger**, not from mutable balances:
- A charge (unpaid trip fare, jama due, salary accrual) → `ledger_entry` with `direction = RECEIVABLE | PAYABLE`.
- A payment → `payment` + `payment_allocation` rows linking to ledger entries (oldest-first by default).
- Party balance = Σ entries − Σ allocations. Corrections are new reversing entries, never edits of history.

### 5.5 Migrations
- Drift schema versioning with step-by-step migrations and generated schema snapshots in the repo.
- Migration tests: open DB at vN-1 fixture → migrate → assert data intact.
- Never destructive without a pre-migration local backup file.

---

## 6. Business Logic Modules

### 6.1 Profit Engine (`core/profit`)
Pure functions over plain data → easily property-tested.

```dart
ProfitSummary computeProfit({
  required Iterable<Trip> trips,
  required Iterable<DayLog> dayLogs,
  required Iterable<JamaEntry> jama,
  required Iterable<Expense> expenses,
  required Iterable<DriverCost> driverCosts,
  required ProfitOptions options, // cash vs accrual, amortize fixed costs
});
```
- Output: gross income, variable costs, driver cost, operating profit, fixed costs, net profit, plus derived metrics (profit/km, fuel %, etc.).
- Owner-borne vs. driver-borne resolved by `business_model` + `paid_by`.
- Amortization: fixed monthly costs spread over days in the month when enabled.
- For dashboard speed, daily aggregates are computed via SQL (`GROUP BY date, vehicle`) and cached in a `daily_rollup` view/table refreshed on writes, not recomputed from raw rows each time.

### 6.2 Driver Pay Calculator
Strategy pattern per `pay_model` (`Salary`, `DailyWage`, `PerTrip`, `Commission`, `Jama`, `Mixed`) producing accruals as `ledger_entry` rows. Accrual runs:
- On trip/day-log save (commission, per-trip).
- Nightly via local scheduled task / app-open catch-up (salary, daily wage, based on attendance).

### 6.3 Jama Generator
- On app open and via WorkManager daily: for each active JAMA assignment, **idempotently** create missing `jama_entry` rows from `start_date` → today, skipping off-days and paused dates.
- Idempotency via unique key `(assignment_id, due_date)`.
- Server also runs a fallback generation job so cross-device edits stay consistent (unique constraint prevents duplicates).

### 6.4 Fuel Efficiency
Computed from consecutive fuel expenses with odometer: `km / qty`. Outlier detection: flag when efficiency drops > 20% below the vehicle's rolling median.

---

## 7. Sync Design

### 7.1 Model
Offline-first, **outbox + cursor-based delta sync**.

1. Every local write runs in one transaction: update row + insert `outbox` op + insert `audit_log`.
2. **Push:** sync engine batches outbox ops (`POST /rpc/sync_push`, ≤ 200 ops). Server applies each op idempotently (keyed by op id) and returns accepted/conflicted results.
3. **Pull:** `GET /rpc/sync_pull?since=<cursor>` returns rows changed since the server cursor (server-assigned monotonic `server_seq`), including tombstones. Client upserts in a transaction and advances cursor.
4. Triggers: app foreground, after local write (debounced 5 s), connectivity regained, WorkManager periodic (15–60 min).

### 7.2 Conflict Resolution
- Granularity: **per field** (column) last-write-wins using `(updated_at, device_id)` tiebreak.
- Server stores per-row `field_versions` (JSONB) only for tables with likely concurrent edits (trip, expense, jama_entry); simple rows use row-level LWW.
- **Ledger and payments are append-only** → no conflicts by design; "edits" are reversal + new entry.
- Deleted-vs-edited: deletion wins unless edit is newer than delete and user confirms restore (surfaced in a "sync conflicts" screen — rare).
- Multi-device and driver-companion edits tagged with `author_id` for audit.

### 7.3 Failure handling
- Exponential backoff with jitter; per-op `attempts` counter; poison ops (4xx validation) moved to a "needs attention" list, not retried forever.
- Sync is resumable and idempotent; app kill mid-sync is safe.
- Clock skew: server stamps `server_seq`; client `updated_at` used only for LWW tiebreak, clamped to server time ± 24 h to ignore badly set phone clocks.

### 7.4 Files (receipts, documents, photos)
- Saved to app storage immediately; path in DB; compressed (≈ 1280 px, JPEG q70).
- Upload queue separate from row sync; Wi-Fi-only by default; path replaced by storage key on success.

---

## 8. Backend Design

### 8.1 Postgres schema
- Mirrors client tables (snake_case, `bigint` minor units, `uuid` ids), plus `server_seq bigserial` per table (or one global sequence), `device_id`, `author_id`.
- `owner_id` on every row; **Row-Level Security**: `owner_id = auth.uid()` for owners; companion drivers get restricted policies via an `owner_membership(owner_id, user_id, role)` table.
- Unique constraints mirror client invariants (e.g., `(assignment_id, due_date)`).

### 8.2 API surface
| Endpoint | Purpose |
|---|---|
| Auth (Supabase) | Phone OTP sign-in, refresh tokens |
| `rpc/sync_push` | Apply batch of ops transactionally per op |
| `rpc/sync_pull` | Delta since cursor, paginated (≤ 500 rows/table/page) |
| `rpc/invite_driver` | Create membership invite, send SMS |
| `rpc/accept_invite` | Driver joins owner scope |
| Storage | Signed-URL uploads for receipts |
| `rpc/export_all` | Full-data export job (JSON/CSV zip) |
| `rpc/delete_account` | Hard-delete after grace period |

### 8.3 Validation (defense in depth)
Server re-validates every op: amounts ≥ 0, FK ownership, allowed status transitions, role permissions (driver cannot edit past entries; entries from driver enter `pending_approval`).

### 8.4 Backups & operations
- Managed Postgres daily backups + PITR; weekly restore drill.
- Per-owner "backup history" (paid): periodic snapshot export to storage.
- Observability: Sentry (app + edge functions), structured logs, sync-error dashboard.

---

## 9. Security & Privacy

| Area | Design |
|---|---|
| Auth | Phone OTP; short-lived JWT + refresh; OTP rate-limit + device binding; SMS fallback provider |
| Local data | SQLCipher; key generated on first run and stored in Android Keystore (`flutter_secure_storage`) |
| App lock | PIN (salted hash, Keystore) + biometrics; auto-lock timeout; screen-capture blocked on sensitive screens (`FLAG_SECURE`, optional) |
| Transport | TLS 1.2+, certificate pinning considered for v2 |
| Tenant isolation | RLS everywhere; automated tests assert cross-tenant access fails |
| PII minimization | NID optional, stored encrypted; receipts private bucket with signed URLs |
| Roles | `owner`, `driver` (v1.2), `manager/partner` (v2) via `owner_membership` |
| Deletion | User-initiated account deletion → soft-delete 14 days → purge DB rows + storage |
| Abuse | Rate limiting on RPCs; payload size caps; op batch limits |
| Backups on device | Android auto-backup disabled for the DB file (we manage our own) |

---

## 10. Reports, PDF & Export

- **Queries:** reporting runs against local SQLite using indexed range scans + `daily_rollup`; target < 300 ms for 1 year × 5 vehicles.
- **PDF:** `pdf` package with embedded **Noto Sans Bengali** (subset to keep size down); templates: daily summary, monthly P&L, driver statement, dues statement. Generated on-device in an isolate to avoid jank.
- **Excel/CSV:** `excel`/CSV writer in isolate; UTF-8 with BOM for Excel Bangla compatibility.
- **Share:** `share_plus` → WhatsApp/Messenger; PDF → image fallback for chat previews.
- **Charts:** `fl_chart`; max ~366 points rendered, downsampled beyond that.

---

## 11. Notifications & Background Work

- **Local notifications** (`flutter_local_notifications` + exact/inexact alarms where permitted): end-of-day prompt, jama collection time, document/service expiry.
- Rescheduled on boot, timezone change, and after settings changes (`BOOT_COMPLETED` receiver).
- **WorkManager** periodic tasks: jama generation, sync, reminder rescheduling. Must tolerate OEM battery killers (Xiaomi/Oppo/Vivo) → catch-up on app open is the correctness path; background is best-effort.
- **FCM push** only for: driver entry awaiting approval, invite accepted, sync-hint (optional).
- Onboarding nudge to disable battery optimization for reliable reminders.

---

## 12. Localization & UX Engineering

- `flutter_localizations` + ARB files (`app_bn.arb`, `app_en.arb`); no hard-coded strings (lint-enforced).
- Numeral style independent of language (setting); all numbers go through a single `NumberFormatter`.
- Fonts: bundled Noto Sans Bengali (variable, subset) for consistent shaping on old devices.
- Input: custom numeric keypad widget with big keys, quick-amount chips, ৳ prefix; no system keyboard for amounts.
- Text scaling tested to 200%; touch targets ≥ 48 dp; semantic labels in both languages.
- Performance: `ListView.builder` + pagination (keyset on `(date, id)`), `const` widgets, avoid rebuilding whole lists via Drift stream granularity.

---

## 13. Testing Strategy

| Layer | Approach | Tooling |
|---|---|---|
| Money & profit engine | Unit + property-based tests (invariants: Σ parts = total, no rounding loss, order independence) | `test`, `glados` |
| Pay calculators, jama generator | Table-driven unit tests incl. off-days, pauses, partial payments, oldest-first allocation | `test` |
| DB & migrations | In-memory Drift tests; migration fixtures for every schema version | `drift_dev`, `test` |
| Sync | Simulated client/server with fault injection (drop, duplicate, reorder, clock skew, kill mid-batch) | custom harness |
| Backend RLS | SQL tests asserting cross-tenant denial per table/role | `pgTAP` |
| Widgets | Golden tests for key screens in bn/en, 100% & 200% text scale | `flutter_test` |
| Integration | Critical flows: first trip < 6 taps, jama collect, driver payout, offline→online sync | `integration_test` |
| Device matrix | Low-end Android (Android 8, 2 GB) smoke on Firebase Test Lab / local devices | manual + FTL |

Coverage gate: ≥ 90% on `core/money`, `core/profit`, pay/jama/ledger domain; ≥ 70% overall.

---

## 14. CI/CD & Environments

- **Repo:** monorepo (`app/`, `backend/` migrations & edge functions, `docs/`).
- **CI (GitHub Actions):** format → analyze → unit/widget tests → pgTAP → build APK size check (fail > 30 MB) → upload artifacts.
- **Environments:** `dev`, `staging`, `prod` Supabase projects; Flutter flavors with separate app IDs.
- **Release:** tagged builds → AAB to Play Console internal → closed beta → staged rollout (5% → 25% → 100%).
- **Versioning:** SemVer; DB schema version tied to app build; server accepts clients within N-1 schema versions (`min_supported_version` flag forces update when needed).
- **Feature flags:** remote config for gradual rollouts (driver companion, accrual toggle).
- **Crash/analytics:** Sentry + privacy-respecting event analytics (opt-out), no financial values in events.

---

## 15. Performance Budget

| Metric | Budget |
|---|---|
| Cold start (low-end) | < 3 s to interactive |
| Add-entry save | < 200 ms |
| Dashboard load (1 yr data) | < 300 ms |
| Report PDF generation (monthly, 5 vehicles) | < 3 s, off main isolate |
| Sync push of 200 ops | < 5 s on 3G |
| Idle memory | < 150 MB |
| APK/AAB | < 30 MB (R8 shrink, font subsetting, split-per-ABI) |

---

## 16. Roadmap Alignment

| Release | Technical work |
|---|---|
| **v1.0 MVP** | Drift schema + migrations, Money/Profit engine, vehicles/drivers/trips/day-log/expenses, basic pay calc, rollups, PDF share, OTP auth, outbox sync + backup, Bangla l10n |
| **v1.1** | Jama generator, ledger/payments/allocations, local notifications, documents & reminders |
| **v1.2** | Memberships/RLS for drivers, approval queue, clients/routes, Excel export, service schedule |
| **v2.0** | Manager/partner roles, payment links (bKash/Nagad APIs), income certificate PDF, iOS build, cert pinning, analytics warehouse |

---

## 17. Key Risks & Mitigations (Technical)

| Risk | Mitigation |
|---|---|
| Sync bugs corrupt money data | Append-only ledger, idempotent ops, fault-injection tests, server re-validation |
| OEM battery killers break reminders/jama | Catch-up-on-open logic is authoritative; background work best-effort |
| SQLCipher + Drift build complexity/APK size | Spike early; fall back to OS-level encryption + Keystore-wrapped export if blocked |
| Bengali text shaping/PDF font issues | Early PDF spike with real samples; bundled font; golden tests |
| Phone-clock errors | Server `server_seq`, clamped timestamps, edit-history UI |
| Schema drift between app versions | `min_supported_version` gate, N-1 compatibility tests |
| SMS OTP cost/deliverability in BD | Two-provider failover, per-number rate limits, consider WhatsApp OTP later |

---

## 18. Open Technical Questions

1. Supabase vs. self-hosted Postgres + small Node API (data residency, SMS gateway integration, cost at scale)?
2. Is per-field LWW worth the complexity at MVP, or ship row-level LWW and upgrade for v1.2 driver companion?
3. Do we need multi-device for a single owner in v1.0, or is single-device + restore sufficient?
4. Accrual vs. cash view: compute both always, or only on toggle (storage vs. CPU trade-off)?
5. Voice entry (Bangla STT) — on-device model feasibility on 2 GB devices?
6. Minimum Android version: 8 (API 26) vs. 6 (API 23) given the target user device base — check market data.
