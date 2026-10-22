# Vehicle Khata — Sprint-wise Technical Implementation Plan

> Derives from [feature-spec.md](feature-spec.md) and [technical-design.md](technical-design.md). Task IDs are stable references (e.g. `S2-T4`) for tickets and commits.

- **Status:** Draft v0.1
- **Cadence:** 2-week sprints (assumes a team of ~2–3 engineers; scale durations if solo)
- **Estimates:** story points (SP) — 1 SP ≈ half a day of focused work
- **Timeline:** 14 sprints ≈ 28 weeks → MVP (v1.0) at end of Sprint 7, v1.1 at Sprint 10, v1.2 at Sprint 13, hardening at Sprint 14

---

## 0. Working Agreements

| Topic | Agreement |
|---|---|
| Definition of Done | Code reviewed, unit tests for domain logic, widget/golden test for new screens (bn + en), no analyzer warnings, no hard-coded strings, works offline, APK size check passes |
| Branching | Trunk-based; short-lived feature branches; PRs ≤ 400 lines where possible |
| Demo | Each sprint ends with a demo on a **low-end Android device** |
| Tracking | One ticket per task below; carry-over reviewed in retro |
| Capacity | Plan to ~70% of capacity; 30% buffer for bugs, review, spikes |
| Priority labels | P0 (must), P1 (should), P2 (could) |

### Roadmap at a glance

| Sprint | Theme | Release |
|---|---|---|
| 0 | Foundations, spikes, CI | — |
| 1 | Core infra: DB, Money, i18n, design system | — |
| 2 | Auth, onboarding, vehicles | — |
| 3 | Drivers & assignments, pay models | — |
| 4 | Trip logging & expenses | — |
| 5 | Quick Day Log (CNG mode), profit engine, dashboard | — |
| 6 | Sync & backup, reports/PDF share | — |
| 7 | MVP hardening & beta | **v1.0** |
| 8 | Jama module | — |
| 9 | Ledger, dues, payments | — |
| 10 | Notifications, documents, reminders | **v1.1** |
| 11 | Clients, routes, trucks | — |
| 12 | Driver companion & RLS roles | — |
| 13 | Exports, service schedule, analytics | **v1.2** |
| 14 | Hardening, performance, store launch | GA |

---

## Sprint 0 — Foundations & Spikes (Week 0–1, shortened)

**Goal:** Remove top technical risks and set up the delivery pipeline.

| ID | Task | SP | Pri | Details / Acceptance |
|---|---|---|---|---|
| S0-T1 | Create monorepo (`app/`, `backend/`, `docs/`) | 1 | P0 | README, `.editorconfig`, license, issue/PR templates |
| S0-T2 | Flutter project scaffold with flavors (`dev`, `staging`, `prod`) | 3 | P0 | Separate app IDs, icons, launch configs |
| S0-T3 | CI pipeline (GitHub Actions) | 3 | P0 | format, analyze, test, build APK, fail if > 30 MB |
| S0-T4 | **Spike:** Drift + SQLCipher on Android 8, 2 GB device | 3 | P0 | Open encrypted DB, insert 50k rows, measure open time & APK delta; decision doc |
| S0-T5 | **Spike:** Bengali PDF generation with embedded Noto Sans Bengali | 3 | P0 | Render sample with conjuncts (যুক্তাক্ষর), numerals; verify on device and in WhatsApp preview |
| S0-T6 | **Spike:** Phone OTP via Supabase + BD SMS gateway | 3 | P0 | End-to-end OTP on a real BD number; cost/delivery notes |
| S0-T7 | Supabase projects (dev/staging/prod), migration tooling | 2 | P0 | `supabase/migrations` in repo, CI applies to staging |
| S0-T8 | Sentry integration (app) + crash test | 1 | P1 | Source maps/obfuscation symbols uploaded |
| S0-T9 | Architecture decision records (ADR) folder | 1 | P1 | ADRs for Flutter, Drift, Supabase, Riverpod |

**Exit criteria:** spikes documented with go/no-go; CI green on an empty app.

---

## Sprint 1 — Core Infrastructure

**Goal:** Reusable base: database, money, localization, UI kit.

| ID | Task | SP | Pri | Details / Acceptance |
|---|---|---|---|---|
| S1-T1 | Folder structure + lint rules (`very_good_analysis` or equivalent) | 2 | P0 | Domain layer forbidden from importing Flutter/Drift (import-lint) |
| S1-T2 | `Money` value type (integer poisha) | 3 | P0 | add/sub/compare, `percentOf(basisPoints)`, rounding rules; property tests |
| S1-T3 | Formatters: ৳ with lakh/crore grouping, Bangla/Latin numerals | 3 | P0 | Single `NumberFormatter`; golden tests for sample values |
| S1-T4 | Drift database bootstrap with SQLCipher + key in Keystore | 5 | P0 | Key generated on first run; DB unreadable without key |
| S1-T5 | Base table mixin (`id` UUIDv7, `created_at`, `updated_at`, `deleted_at`, `rev`, `dirty`, `owner_id`) | 3 | P0 | Generic repository helper for soft delete |
| S1-T6 | Migration framework + schema snapshot tests | 3 | P0 | Test: vN-1 fixture → vN passes |
| S1-T7 | i18n setup (ARB bn/en), locale switcher, lint for hard-coded strings | 3 | P0 | Default Bangla; persisted setting |
| S1-T8 | Design system: theme, colors, typography (Noto Sans Bengali), spacing, 48 dp targets | 3 | P0 | Light theme first; text scale up to 200% |
| S1-T9 | Core widgets: `AmountKeypad`, `QuickChips`, `BigButton`, `EmptyState`, `ListTile` variants | 5 | P0 | Storybook-style gallery screen; goldens (bn/en) |
| S1-T10 | Router (`go_router`) + app shell + bottom navigation (Home, Entries, Reports, More) | 3 | P0 | Deep-link-ready |
| S1-T11 | Riverpod DI setup + test overrides | 2 | P0 | In-memory DB provider for tests |
| S1-T12 | Settings storage (shared prefs + secure storage wrapper) | 2 | P1 | Language, numeral style, profit view |

**Exit criteria:** app boots to empty shell in bn/en; encrypted DB opens on low-end device.

---

## Sprint 2 — Auth, Onboarding & Vehicles

**Goal:** User can sign in, finish onboarding, and manage vehicles. (Spec F1, F2)

| ID | Task | SP | Pri | Details / Acceptance |
|---|---|---|---|---|
| S2-T1 | Backend: `profiles` table, RLS baseline, `owner_id` conventions | 3 | P0 | pgTAP test for cross-tenant denial |
| S2-T2 | Phone OTP screens (number entry, OTP, resend timer, errors) | 5 | P0 | bn/en errors, rate-limit messaging, 6-digit autofill (SMS Retriever) |
| S2-T3 | Auth repository + session persistence + token refresh | 3 | P0 | Works after cold start offline (cached session) |
| S2-T4 | Offline-first gate: allow local use before first login? | 2 | P1 | Decision implemented: "continue without account" → link later |
| S2-T5 | Onboarding flow: language → role → add first vehicle → business model | 5 | P0 | Skip-able; resumable if killed mid-way |
| S2-T6 | Vehicle table, DAO, repository, domain entity | 3 | P0 | Types and fuel types from spec; migrations |
| S2-T7 | Vehicle list screen with status chips & search | 3 | P0 | Keyset pagination; empty state |
| S2-T8 | Add/Edit vehicle form (photo, reg no, business model) | 5 | P0 | Image compress (≈1280 px, q70), validation, duplicate reg-no warning |
| S2-T9 | Vehicle archive / restore / status change | 2 | P0 | Archived hidden by default; kept in reports |
| S2-T10 | App lock: PIN + biometric (optional) | 5 | P1 | Salted hash in Keystore; auto-lock timeout |
| S2-T11 | Unit/widget tests for auth & vehicle flows | 3 | P0 | ≥ 70% coverage on feature |

**Exit criteria:** new user installs → signs in → adds vehicle in < 2 minutes.

---

## Sprint 3 — Drivers, Assignments & Pay Models

**Goal:** Manage drivers and how they are paid. (Spec F6 foundation)

| ID | Task | SP | Pri | Details / Acceptance |
|---|---|---|---|---|
| S3-T1 | Driver + assignment tables, DAOs, repos | 3 | P0 | One active assignment per vehicle (constraint + test) |
| S3-T2 | Driver list/detail UI; add/edit driver (license, expiry, photo) | 5 | P0 | NID optional, encrypted field |
| S3-T3 | Assignment screen: assign/unassign/switch driver | 3 | P0 | History preserved; effective dates |
| S3-T4 | Pay model domain: sealed class (`Salary`, `DailyWage`, `PerTrip`, `Commission`, `Jama`, `Mixed`) | 5 | P0 | JSON param schema + versioning; validation |
| S3-T5 | Pay model configuration UI per assignment | 5 | P0 | Commission basis (before/after expenses), percent in basis points |
| S3-T6 | Pay calculator strategies (pure Dart) | 5 | P0 | Table-driven tests incl. rounding, zero cases |
| S3-T7 | Attendance table + UI (present/absent/half-day) | 3 | P0 | Calendar grid; auto-present hook reserved for trips/day-logs |
| S3-T8 | Advances: create/list, link to payouts | 3 | P0 | Running balance on driver card |
| S3-T9 | Payout flow: period, earned − advances − paid = net | 5 | P0 | Creates payout record; idempotent per period |
| S3-T10 | Audit log write-through on all mutations | 3 | P1 | Generic repository hook |
| S3-T11 | Tests | 3 | P0 | Pay calculators ≥ 90% coverage |

**Exit criteria:** salaried driver balance matches spec §6.4 example.

---

## Sprint 4 — Trip Logging & Expenses

**Goal:** Log trips with expenses at speed. (Spec F3, F5)

| ID | Task | SP | Pri | Details / Acceptance |
|---|---|---|---|---|
| S4-T1 | Expense category table + seed defaults (bn/en) | 2 | P0 | Editable; archive instead of delete |
| S4-T2 | Trip + expense tables/DAOs/repos | 5 | P0 | Indexes per design doc |
| S4-T3 | Trip quick-add screen (keypad, vehicle/driver defaults) | 8 | P0 | Create trip with fare + 1 expense in ≤ 6 taps |
| S4-T4 | Expense chips (⛽ 🛣 🅿 👷) + inline amount entry | 5 | P0 | Two-tap add; custom category sheet |
| S4-T5 | Live profit preview while typing | 3 | P0 | Uses profit engine v0 |
| S4-T6 | Payment status (paid/partial/unpaid) + received amount | 3 | P0 | Validation received ≤ fare |
| S4-T7 | Driver pay auto-calc per trip from assignment | 3 | P0 | Editable override with flag |
| S4-T8 | From/To autocomplete from history | 3 | P1 | Local FTS or prefix index |
| S4-T9 | Repeat trip + return leg (linked trip) | 3 | P1 | One-tap duplicate |
| S4-T10 | Trip list (filters: vehicle, date, status) + detail + edit/delete | 5 | P0 | Soft delete; audit entry |
| S4-T11 | Vehicle-level expenses (not tied to trip/day) | 3 | P0 | Repair/service entry form |
| S4-T12 | Receipt photo attach (local path, compressed) | 3 | P1 | Queue prepared for upload (Sprint 6) |
| S4-T13 | Fuel entry fields: qty, odometer; efficiency calc | 3 | P1 | km/litre or km/m³; outlier flag |
| S4-T14 | Tests (profit preview, trip validation, DAO) | 3 | P0 | |

**Exit criteria:** pickup trip example (spec §13) yields ৳2,200 profit.

---

## Sprint 5 — Day Log, Profit Engine & Dashboard

**Goal:** CNG daily mode and trustworthy profit numbers. (Spec F4, F8, F9 part)

| ID | Task | SP | Pri | Details / Acceptance |
|---|---|---|---|---|
| S5-T1 | `day_log` table/DAO/repo; one log per vehicle/day (merge on re-entry) | 3 | P0 | Unique `(vehicle_id, log_date)` |
| S5-T2 | Home "Today" card with big **+ Add income** button | 5 | P0 | Running counter (+৳ taps) with undo |
| S5-T3 | Day close screen: net profit + settlement prompt | 3 | P0 | Driver pay / jama hook points |
| S5-T4 | Gas refill entry (qty, cost, odometer) | 3 | P0 | Shares code with fuel expense |
| S5-T5 | Profit engine full implementation (cash vs accrual, amortized fixed costs) | 8 | P0 | Matches formulas in design §6.1; property tests |
| S5-T6 | `daily_rollup` table maintained on writes (triggers or repo hooks) | 5 | P0 | Rebuild command for repair; consistency test vs raw |
| S5-T7 | Dashboard: today/week/month profit, per-vehicle ranking | 5 | P0 | < 300 ms with 1 yr data (benchmark test) |
| S5-T8 | Charts: profit trend, income vs cost, expense donut (`fl_chart`) | 5 | P0 | Downsample > 366 points; dataviz-accessible colors |
| S5-T9 | Attendance auto-present from trip/day-log | 2 | P1 | |
| S5-T10 | Seed-data generator for perf testing (5 vehicles × 1 yr) | 2 | P1 | Debug-only |
| S5-T11 | Tests: CNG example (spec §13) = ৳2,100 | 3 | P0 | |

**Exit criteria:** owner-driver can complete daily flow in < 15 s per entry.

---

## Sprint 6 — Sync, Backup & Reports

**Goal:** Data safe in the cloud; shareable reports. (Spec F12, F13 basic, F9 reports)

| ID | Task | SP | Pri | Details / Acceptance |
|---|---|---|---|---|
| S6-T1 | Postgres schema mirror + `server_seq`, RLS policies | 8 | P0 | pgTAP for every table |
| S6-T2 | Outbox: write-through in all repositories (single transaction) | 5 | P0 | Op id, entity, payload; compaction of repeated edits |
| S6-T3 | `sync_push` RPC (idempotent, per-op validation) | 8 | P0 | Server re-validation rules from design §8.3 |
| S6-T4 | `sync_pull` RPC with cursor + pagination + tombstones | 5 | P0 | ≤ 500 rows/table/page |
| S6-T5 | Client sync engine: triggers, backoff + jitter, poison-op list | 8 | P0 | Foreground, debounce 5 s, connectivity regain |
| S6-T6 | Conflict resolution v1 (row-level LWW, clock clamp ±24 h) | 3 | P0 | Per-field deferred (open question 2) |
| S6-T7 | Restore on new device (phone login → full pull) | 5 | P0 | Progress UI; resumable |
| S6-T8 | Sync status UI (last synced, pending count, errors) | 3 | P0 | Needs-attention list |
| S6-T9 | Fault-injection sync test harness | 5 | P0 | Drop/dup/reorder/kill mid-batch |
| S6-T10 | Receipt upload queue (Wi-Fi only default), signed URLs | 5 | P1 | Replace local path with storage key |
| S6-T11 | PDF templates: daily summary, monthly P&L (Bangla font) | 8 | P0 | Isolate generation; share via WhatsApp |
| S6-T12 | Report screens: daily, monthly, vehicle, expense | 5 | P0 | Filters per spec F9 |

**Exit criteria:** airplane-mode usage for a day, reconnect, data identical on server and on a second device restore.

> Sprint 6 is overloaded (~80 SP). If capacity is tight, move S6-T10 and half of S6-T12 into Sprint 7.

---

## Sprint 7 — MVP Hardening & Beta (**v1.0**)

**Goal:** Ship a stable closed beta.

| ID | Task | SP | Pri | Details / Acceptance |
|---|---|---|---|---|
| S7-T1 | Driver statement PDF (salary/advances/payout) | 3 | P0 | Share via WhatsApp |
| S7-T2 | Manual full-data export (JSON/CSV zip) | 3 | P1 | |
| S7-T3 | Settings screen: language, numerals, profit view, units | 3 | P0 | |
| S7-T4 | Performance pass on low-end device; startup & list jank fixes | 5 | P0 | Budgets from design §15 |
| S7-T5 | Accessibility pass: 200% text, TalkBack labels, contrast | 3 | P0 | |
| S7-T6 | Integration tests for critical flows | 5 | P0 | Onboard → trip → report; offline → sync |
| S7-T7 | Analytics (opt-out) + crash dashboards | 3 | P1 | No money values in events |
| S7-T8 | Play Store listing (bn/en), privacy policy, data-safety form | 3 | P0 | |
| S7-T9 | Closed beta with 10–20 real owners (CNG, pickup, truck) | 3 | P0 | Feedback form + interviews |
| S7-T10 | Bug bash & triage; fix P0/P1 | 8 | P0 | |
| S7-T11 | Migration dry-run: upgrade test from earliest beta build | 2 | P0 | |

**Exit criteria:** crash-free ≥ 99%, activation flow validated by real users → **tag v1.0**.

---

## Sprint 8 — Jama Module (Spec F7)

| ID | Task | SP | Pri | Details / Acceptance |
|---|---|---|---|---|
| S8-T1 | `jama_entry` table + unique `(assignment_id, due_date)`; jama config (amount, frequency, off-days, deposit, cost split) | 5 | P0 | |
| S8-T2 | Idempotent jama generator (on app open + WorkManager) | 5 | P0 | Skips off-days/pauses; backfills missed days |
| S8-T3 | Server fallback generator (scheduled function) | 3 | P1 | Unique constraint prevents duplicates |
| S8-T4 | Collect jama UI: paid/partial/unpaid/waived, prefilled amount | 5 | P0 | One tap for full payment |
| S8-T5 | Jama calendar view (green/yellow/red/grey) | 5 | P0 | |
| S8-T6 | Baki rollover to driver due; oldest-first settlement | 5 | P0 | Property tests: Σ allocations ≤ payment |
| S8-T7 | Vehicle off-road (garage) pause/waive | 3 | P0 | |
| S8-T8 | Deposit tracking + refund on exit | 3 | P1 | |
| S8-T9 | Owner profit for JAMA vehicles (income = jama collected) | 5 | P0 | Profit engine branch + tests (spec §13 = ৳8,200) |
| S8-T10 | Jama report: expected vs collected, defaulters, rate % | 5 | P0 | |
| S8-T11 | Tests (generator edge cases: DST-free but month boundaries, start mid-month, reassignments) | 5 | P0 | |

---

## Sprint 9 — Ledger, Dues & Payments (Spec F10)

| ID | Task | SP | Pri | Details / Acceptance |
|---|---|---|---|---|
| S9-T1 | Append-only `ledger_entry`, `payment`, `payment_allocation` tables | 5 | P0 | Reversal pattern only; no updates |
| S9-T2 | Migrate trips/jama/payout accruals to ledger postings | 8 | P0 | Backfill migration with verification totals |
| S9-T3 | Party balance queries + aging buckets (0–7, 8–30, 30+) | 5 | P0 | |
| S9-T4 | Dues screen (by party, direction) + party statement | 5 | P0 | |
| S9-T5 | Record payment with allocation UI (auto oldest-first, manual override) | 8 | P0 | |
| S9-T6 | Reimbursable driver-paid expenses → payable to driver | 3 | P0 | |
| S9-T7 | Reminder text templates (bn/en) + SMS/WhatsApp intent | 3 | P1 | |
| S9-T8 | Statement PDF/image share | 3 | P1 | |
| S9-T9 | Sync updates: ledger tables append-only semantics server-side | 5 | P0 | Reject updates/deletes |
| S9-T10 | Reconciliation tool: ledger vs. rollups consistency check (debug + nightly test) | 3 | P0 | |
| S9-T11 | Tests (allocation, reversals, aging) | 5 | P0 | |

---

## Sprint 10 — Notifications, Documents & Reminders (**v1.1**)

| ID | Task | SP | Pri | Details / Acceptance |
|---|---|---|---|---|
| S10-T1 | Local notification service (channels, quiet hours) | 5 | P0 | Reschedule on boot/timezone change |
| S10-T2 | End-of-day prompt; jama-time reminder; dues nudge | 5 | P0 | Skips if already logged |
| S10-T3 | Documents: table, UI, photo capture, expiry | 5 | P0 | Vehicle and driver docs |
| S10-T4 | Expiry reminders (30/7/1 days) | 3 | P0 | |
| S10-T5 | Service reminders (km/date) + odometer log | 5 | P1 | Uses trip distance when available |
| S10-T6 | Weekly summary notification | 2 | P1 | |
| S10-T7 | OEM battery-optimization onboarding hint | 2 | P1 | Deep link to settings by vendor |
| S10-T8 | Regression + beta round 2 on jama/dues | 5 | P0 | |
| S10-T9 | Release v1.1 (staged rollout) | 2 | P0 | |

---

## Sprint 11 — Clients, Routes & Trucks (Spec F15)

| ID | Task | SP | Pri | Details / Acceptance |
|---|---|---|---|---|
| S11-T1 | Client + route tables/UI | 5 | P0 | |
| S11-T2 | Trip form: pick client/route → suggest fare/toll | 5 | P0 | |
| S11-T3 | Advance received before trip + balance after delivery | 5 | P0 | Ledger postings |
| S11-T4 | Multi-stop trip & load details | 5 | P1 | |
| S11-T5 | Client statement + receivables aging | 5 | P0 | |
| S11-T6 | Trip report by route/client | 3 | P0 | |
| S11-T7 | Truck-specific expense chips (helper, police, weighbridge) | 2 | P1 | |
| S11-T8 | Sync schema + RLS for new tables | 3 | P0 | |
| S11-T9 | Tests + truck-owner beta | 5 | P0 | Spec §6.2 flow = ৳9,400 trip profit |

---

## Sprint 12 — Driver Companion & Roles (Spec F14)

| ID | Task | SP | Pri | Details / Acceptance |
|---|---|---|---|---|
| S12-T1 | `owner_membership` table; role-aware RLS policies | 8 | P0 | pgTAP matrix: owner / driver / stranger |
| S12-T2 | Invite flow: owner invites by phone; SMS; accept | 5 | P0 | |
| S12-T3 | Driver app mode: restricted navigation & data scope | 8 | P0 | Own earnings, advances, jama due only |
| S12-T4 | Driver entry submission → `pending_approval` status | 5 | P0 | |
| S12-T5 | Owner approval queue (approve/reject/edit) | 5 | P0 | |
| S12-T6 | FCM push: approval requests, invite accepted | 3 | P1 | |
| S12-T7 | Per-field conflict resolution upgrade (trip, expense, jama) | 8 | P1 | Decision from open question 2 |
| S12-T8 | Shared balance view for owner + driver | 3 | P0 | |
| S12-T9 | Security review & pen-test checklist | 3 | P0 | |

---

## Sprint 13 — Exports, Analytics & Polish (**v1.2**)

| ID | Task | SP | Pri | Details / Acceptance |
|---|---|---|---|---|
| S13-T1 | Excel/CSV export (UTF-8 BOM) for all reports | 5 | P0 | In isolate |
| S13-T2 | Monthly "khata page" print layout (loan proof) | 3 | P1 | |
| S13-T3 | Fuel efficiency analytics & anomaly alerts | 5 | P1 | Rolling-median logic |
| S13-T4 | Break-even / EMI tracking per vehicle | 3 | P1 | |
| S13-T5 | Subscription: free vs paid gating, Play Billing, bKash/Nagad manual flow | 8 | P0 | Server-verified entitlements |
| S13-T6 | Remote config + feature flags | 3 | P1 | |
| S13-T7 | Backup history (paid) | 3 | P1 | |
| S13-T8 | Voice entry spike (Bangla STT) | 3 | P2 | Go/no-go for v2 |
| S13-T9 | Release v1.2 | 2 | P0 | |

---

## Sprint 14 — Hardening, Performance & Launch

| ID | Task | SP | Pri | Details / Acceptance |
|---|---|---|---|---|
| S14-T1 | Full regression on device matrix (Android 8–14) | 5 | P0 | Low-end focus |
| S14-T2 | Load test backend sync (1k simulated owners) | 5 | P0 | p95 < 1 s |
| S14-T3 | Restore drill from backup (DB + storage) | 2 | P0 | Documented runbook |
| S14-T4 | Account deletion + data export compliance flow | 3 | P0 | 14-day grace |
| S14-T5 | Crash/ANR triage to ≥ 99.5% crash-free | 5 | P0 | |
| S14-T6 | Store assets, ASO (bn/en), marketing landing page | 3 | P1 | |
| S14-T7 | Support tooling: in-app feedback, FAQ, WhatsApp support link | 3 | P1 | |
| S14-T8 | Staged production rollout 5% → 25% → 100% | 2 | P0 | |
| S14-T9 | Post-launch metrics dashboard (activation, retention, entries/day) | 3 | P1 | |

---

## Cross-Cutting Workstreams (every sprint)

| Stream | Ongoing tasks |
|---|---|
| **Testing** | Add tests with each feature; keep coverage gates (≥ 90% money/profit/pay/jama/ledger, ≥ 70% overall) |
| **i18n** | Every string in bn + en before merge; native-speaker review per release |
| **Performance** | Run seed-data perf benchmark in CI nightly; track APK size trend |
| **Security** | Dependency audit each sprint; RLS tests required for each new table |
| **Docs** | Update ADRs, schema docs, runbooks |
| **User research** | 3–5 owner interviews per sprint; feed into backlog grooming |

---

## Dependencies & Critical Path

```
S0 spikes ─► S1 infra ─► S2 auth/vehicles ─► S3 drivers/pay ─► S4 trips/expenses
                                                       │              │
                                                       └──► S5 day log + profit engine
                                                                      │
                                                    S6 sync + reports ┘ ─► S7 MVP
S7 ─► S8 jama ─► S9 ledger/dues ─► S10 notifications (v1.1)
S9 ─► S11 clients/routes ─► S12 companion/RLS roles ─► S13 exports/billing (v1.2) ─► S14 launch
```

Key dependency notes:
- **Ledger (S9)** touches trips, jama and payouts — schedule a backfill migration with verification totals; do not start before S8 is stable.
- **Sync (S6)** must precede any multi-user work (S12). Every new table from S8 on needs migration + sync + RLS in the same sprint.
- **OTP (S2)** depends on S0-T6 SMS gateway decision.

---

## Risk Register (Delivery)

| Risk | Impact | Mitigation | Owner |
|---|---|---|---|
| Sprint 6 overload (sync + PDF) | MVP slips | Split across S6/S7; pull PDF earlier if sync blocks | Tech lead |
| SQLCipher build issues | Blocks S1 | Decided by S0-T4 spike; fallback path in design §17 | Mobile lead |
| Bangla PDF rendering defects | Poor report quality | S0-T5 spike; golden tests; real-user samples | Mobile |
| Ledger migration (S9) corrupts totals | Trust loss | Verification totals, dry-run on beta copies, rollback plan | Backend |
| OEM background kills reminders | Missed jama prompts | Catch-up on open is authoritative | Mobile |
| Beta recruiting delays | Weak validation | Start recruiting in Sprint 4; partner with local garages/unions | Product |
| Scope creep from beta feedback | Delays | Weekly triage; P2 backlog for post-launch | PM |

---

## Estimation Summary

| Phase | Sprints | Approx. SP | Outcome |
|---|---|---|---|
| Foundation | S0–S1 | ~65 | Infra ready |
| MVP build | S2–S7 | ~400 | v1.0 beta |
| Jama & dues | S8–S10 | ~215 | v1.1 |
| Trucks & teams | S11–S13 | ~190 | v1.2 |
| Launch | S14 | ~30 | GA |

*Totals are rough; re-baseline after Sprint 2 using measured velocity.*
