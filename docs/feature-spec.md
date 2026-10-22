# Vehicle Khata — Feature Specification

> Trip and income ledger for vehicle owners: CNG auto-rickshaw, pickup, truck, and rented-rickshaw ("jama") owners.

- **Status:** Draft v0.1
- **Platform:** Mobile (Android first, iOS second)
- **Primary market:** Bangladesh (Bangla + English, BDT ৳)

---

## 1. Vision & Problem

Small vehicle owners in Bangladesh track income in their heads, on scraps of paper, or in a notebook ("khata"). They rarely know the real profit per trip or per day because fuel, tolls, driver pay, and repairs are mixed together. Owners who rent vehicles out on a daily "jama" (fixed rent) also struggle to track who paid, who is behind, and what is owed.

**Vehicle Khata** gives them a fast, simple, offline-friendly ledger that answers one question: **"How much did I actually earn?"**

### Goals
1. Record a trip or a day's income in under 15 seconds.
2. Show true profit per trip, per day, per vehicle, per month.
3. Track driver pay and jama dues without arguments.
4. Work fully offline; sync when connected.
5. Be usable by low-literacy users (Bangla UI, big buttons, icons, numeric keypad).

### Non-Goals (v1)
- Passenger-facing ride booking or dispatch.
- Payment processing / mobile-money integration (record only).
- GPS fleet tracking hardware integration.
- Tax filing.

---

## 2. Target Users & Personas

| Persona | Description | Key needs |
|---|---|---|
| **Owner-driver** | Owns one CNG/pickup and drives it himself | Daily income vs. fuel/gas cost, monthly profit, repair savings |
| **Owner with driver** | Owns 1–5 vehicles, hires drivers on salary or commission | Driver pay tracking, per-vehicle profit, trust/transparency |
| **Jama owner** | Rents rickshaws/CNGs to drivers for a fixed daily amount | Daily jama collection, dues, advances, defaulters |
| **Truck/pickup operator** | Long hauls, per-trip contracts, tolls, helper pay | Trip-level P&L, route history, client payments, advance/balance |
| **Driver (secondary)** | Works for an owner | See own earnings, log trips/expenses, dispute-free records |

---

## 3. Core Concepts / Glossary

| Term | Meaning |
|---|---|
| **Vehicle** | A CNG, rickshaw, pickup, truck, or other asset owned by the user |
| **Trip** | A single paid journey/job with fare and associated costs |
| **Day Log** | Aggregated entry for a day (for vehicles with many small fares, e.g. CNG) |
| **Jama** | Fixed daily/weekly rent paid by a driver to the owner for using a vehicle |
| **Khata** | Ledger book |
| **Expense** | Fuel, gas, toll, police/parking, repair, food, etc. |
| **Driver pay** | Salary, per-trip commission, daily wage, or percentage of income |
| **Due / Baki** | Unpaid balance (client owes owner, driver owes jama, or owner owes driver) |

---

## 4. Feature Overview (Priority)

| ID | Feature | Priority |
|---|---|---|
| F1 | Onboarding & language | P0 |
| F2 | Vehicle management | P0 |
| F3 | Trip logging | P0 |
| F4 | Quick Day Log (CNG mode) | P0 |
| F5 | Expense tracking (fuel, toll, other) | P0 |
| F6 | Driver management & pay | P0 |
| F7 | Jama (rental) management | P0 |
| F8 | Profit calculation engine | P0 |
| F9 | Dashboard & reports | P0 |
| F10 | Dues / Baki ledger | P1 |
| F11 | Maintenance & documents reminders | P1 |
| F12 | Offline mode & cloud backup | P0 |
| F13 | Export & share (PDF/Excel/WhatsApp) | P1 |
| F14 | Driver companion access | P2 |
| F15 | Clients/customers & routes (trucks) | P1 |
| F16 | Notifications & reminders | P1 |
| F17 | Settings, security, subscription | P1 |

---

## 5. Detailed Feature Specifications

### F1. Onboarding & Language
- Language selection first screen: **বাংলা** (default) / English.
- Login via phone number + OTP (no password).
- Role selection: *Owner* / *Driver*.
- Quick setup wizard: add first vehicle → choose business model (Self-driven / Hired driver / Jama rental / Per-trip hauling) → done.
- Optional PIN / biometric lock.

**Acceptance criteria**
- A new user can reach "first trip logged" in < 2 minutes.
- All UI strings available in Bangla and English; numerals can display as Bangla (০–৯) or Latin (0–9) per setting.

---

### F2. Vehicle Management
**Fields:** nickname, type (CNG / Rickshaw / Easy-bike / Pickup / Mini-truck / Truck / Other), registration number, make/model, year, fuel type (CNG / Octane / Petrol / Diesel / Electric), photo, purchase date & price (optional), status (Active / In garage / Sold).

**Business model per vehicle:** 
- `SELF` – owner drives.
- `SALARIED` – driver paid monthly salary.
- `DAILY_WAGE` – driver paid fixed per day.
- `COMMISSION` – driver gets % of income or per-trip amount.
- `JAMA` – driver pays fixed rent to owner; keeps the rest.
- `CONTRACT` – per-trip hauling (trucks/pickups).

**Actions:** add, edit, archive, assign/unassign driver, switch active driver, view vehicle-level summary.

**Rules**
- A vehicle has at most one *active* driver at a time; history of past assignments is kept.
- Archived vehicles stay in historical reports.

---

### F3. Trip Logging
Designed for pickups/trucks/CNG-by-the-ride where individual trips matter.

**Fields**
| Field | Type | Notes |
|---|---|---|
| Vehicle | select | defaults to last used |
| Driver | select | defaults to active driver |
| Date & time | datetime | defaults to now |
| From / To | text + saved places | autocomplete from history |
| Distance (km) | number | optional; or odometer start/end |
| Fare / Income | currency | required |
| Payment status | Paid / Partial / Unpaid | partial records amount received |
| Customer / Client | select/optional | links to F15 |
| Load / Passengers | text | optional (e.g. "5 ton rice") |
| Expenses | list | fuel, toll, parking, helper, police, food, other (see F5) |
| Driver pay for this trip | currency | auto-calculated from the vehicle model; editable |
| Notes / photo | text, image | e.g. challan or memo photo |

**Computed:** `Trip Profit = Fare − Σ trip expenses − driver pay`

**Behaviors**
- **Quick add:** one-screen form with big numeric keypad; expense chips (⛽ Fuel, 🛣 Toll, 🅿 Parking, 👷 Helper) add an amount in two taps.
- **Repeat trip:** duplicate a past trip (same route/fare) with one tap.
- **Round trips:** option to add a return leg as a linked trip.
- **Multi-stop:** optional for trucks.
- Edit/delete with an audit trail (who/when changed).

**Acceptance criteria**
- Create a trip with fare + 1 expense in ≤ 6 taps.
- Profit shown live while typing.

---

### F4. Quick Day Log (CNG / Rickshaw Mode)
CNG and rickshaw drivers don't log each passenger. They want a daily summary.

**Fields:** vehicle, date, total collection (fare), gas/fuel cost, other expenses, driver pay / jama (auto), hours worked or km (optional), notes.

**Features**
- "Today" card on home with a single big **+ Add today's income** button.
- Optional running counter: tap **+৳ amount** repeatedly during the day to accumulate fares.
- Gas station refill entry: amount (৳), litres/m³ (optional), odometer (optional), computes cost per km over time.
- End-of-day close: shows net profit and prompts for jama/driver settlement.
- Mix-and-match: a vehicle can have both day logs and individual trips (e.g., a pickup doing mostly trips).

**Computed:** `Day Profit = Total collection − Σ expenses − driver pay (or − 0 if jama; jama is income to owner, see F7)`

---

### F5. Expense Tracking
**Categories (default, editable):** Fuel/CNG gas, Toll, Parking, Police/Informal, Driver food/allowance, Helper pay, Repair, Spare parts, Tyre, Oil change/service, Washing, Insurance, Registration/Fitness/Tax token, Loan installment (EMI), Other.

**Fields:** amount, category, vehicle, date, linked trip/day log (optional), paid by (Owner / Driver / Client), reimbursable? (Y/N), receipt photo, note.

**Features**
- Expense can be **trip-level**, **day-level**, or **vehicle-level** (e.g., a repair not tied to a trip).
- **Driver-paid expenses** create a reimbursement due from owner to driver (flows into F10).
- Fuel entries track efficiency: km/litre (or km/m³ for CNG), cost per km; flag unusual drops in mileage.
- Recurring expenses (EMI, insurance, monthly parking) auto-posted on schedule.
- Fixed costs can be amortized per day in the profit report (toggle).

---

### F6. Driver Management & Pay
**Driver profile:** name, phone, photo, NID (optional), license number + expiry, address, emergency contact, join date, status.

**Pay models (set per driver–vehicle assignment)**
| Model | Calculation |
|---|---|
| Monthly salary | Fixed amount, accrues daily; deductions for absences/advances |
| Daily wage | Fixed amount × days worked |
| Per-trip fee | Fixed amount per trip |
| Commission % | % of fare (before or after expenses — configurable) |
| Jama | Driver pays owner fixed rent (see F7) |
| Mixed | Base + commission/bonus |

**Features**
- Attendance: mark present/absent/half-day per day (auto-present if a trip/day log exists).
- **Advances:** record cash advances; auto-deduct from next payout.
- **Payouts:** record payments made to driver; running balance (earned − paid − advances).
- Bonus / penalty entries with reason.
- Driver statement (PDF/WhatsApp share) for any period.
- Performance view: income, trips, fuel efficiency, days worked per driver.

---

### F7. Jama (Rental) Management
For owners who rent out vehicles to drivers for a fixed daily/weekly amount.

**Setup per vehicle assignment:** jama amount, frequency (daily / weekly), off-days (e.g., Friday free), grace rules, start date, security deposit (optional), who pays fuel/gas (usually the driver), who pays repairs (configurable split).

**Daily flow**
1. System auto-creates an expected jama entry each due day.
2. Owner marks **Paid / Partial / Unpaid / Waived** (with amount).
3. Unpaid/partial balance rolls into the driver's **Baki** (due) automatically.

**Features**
- Jama calendar view: green (paid), yellow (partial), red (missed), grey (off-day).
- One-tap *Collect jama* with amount pre-filled.
- Late/partial payment tracking and cumulative due per driver.
- Settlement of dues: record lump-sum payments applied oldest-first.
- Deposit tracking and refund on exit.
- Reminders to owner at collection time; optional SMS/WhatsApp reminder text to the driver for dues.
- Vehicle off-road days (garage) can **pause** or **waive** jama for those dates.
- Reports: collected vs. expected, defaulters list, collection rate %.

**Income recognition:** For JAMA vehicles, owner income = jama collected; fuel/gas is the driver's cost unless configured otherwise. Owner profit = jama − owner-borne costs (repairs, installments, etc.).

---

### F8. Profit Calculation Engine
Single source of truth for profit across the app.

```
Gross Income        = Σ fares (trips + day logs) + Σ jama collected
Variable Costs      = fuel + toll + parking + helper + other trip/day expenses (owner-borne)
Driver Cost         = Σ salary accrued / wages / commissions / trip fees (owner-borne)
Operating Profit    = Gross Income − Variable Costs − Driver Cost
Fixed/Vehicle Costs = repair + maintenance + insurance + taxes + EMI (period total or amortized)
Net Profit          = Operating Profit − Fixed/Vehicle Costs
```

**Views:** per trip, per day, per week, per month, per vehicle, per driver, all-vehicles total, custom range.

**Metrics:** profit per km, profit per trip, profit per working day, fuel cost % of income, cost per km, average fare, break-even days (for loan vehicles), jama collection rate.

**Rules**
- "Owner-borne" vs. "driver-borne" is determined by the vehicle's business model and per-expense *paid by* field.
- Unpaid fares are shown as *receivable*, not income, in the **cash** view; shown as income in the **accrual** view. Default = cash; user can toggle.
- All amounts stored as integers in the smallest unit (poisha) to avoid rounding errors; display in ৳.

---

### F9. Dashboard & Reports
**Home dashboard (owner)**
- Today: income, expenses, profit; vehicles active/idle.
- This week / month: profit trend chart.
- Alerts: jama dues, unpaid trips, documents expiring, service due.
- Per-vehicle cards ranked by profit.

**Reports**
| Report | Contents |
|---|---|
| Daily summary | Income, expenses, profit per vehicle |
| Monthly P&L | Income, cost breakdown by category, net profit, MoM comparison |
| Vehicle report | Profit, utilization, fuel efficiency, maintenance spend |
| Driver report | Earnings, advances, payouts, balance, performance |
| Jama report | Expected vs. collected, defaulters |
| Trip report | Filterable by route, client, vehicle, date |
| Expense report | Category pie/bar, trend, top spends |
| Receivables | Unpaid fares & dues aging (0–7, 8–30, 30+ days) |

**Filters:** date range (today/week/month/year/custom), vehicle, driver, category.
**Charts:** line (profit trend), stacked bar (income vs. cost), donut (expense mix).

---

### F10. Dues / Baki Ledger
Unified ledger of money owed in all directions:
- **Client → Owner:** unpaid/partial trip fares.
- **Driver → Owner:** unpaid jama, damage recovery.
- **Owner → Driver:** salary owed, reimbursable expenses.
- **Owner → Others:** mechanics/garage/parts vendors (optional).

**Features**
- Per-party running balance with full transaction history.
- Record payments (cash / bKash / Nagad / bank — label only) with partial allocation.
- "Send reminder" via SMS/WhatsApp with pre-written Bangla/English text.
- Aging buckets and total outstanding on dashboard.
- Statement share as PDF/image.

---

### F11. Maintenance & Document Reminders
- **Service schedule:** by km or date (oil change, tyre rotation, CNG cylinder test, battery).
- **Documents:** registration, fitness certificate, tax token, route permit, insurance, driver license — store photo + expiry date.
- Reminders at 30/7/1 days before expiry.
- Maintenance history per vehicle with cost and workshop name.
- Odometer log (manual or from trip distance).
- Cost-per-km trend to surface "money-pit" vehicles.

---

### F12. Offline Mode & Backup
- **Offline-first:** all create/edit/read operations work without internet; data in local DB (SQLite).
- Background sync when online; conflict resolution = last-write-wins per field, with edit history preserved.
- Automatic cloud backup; restore on a new phone via phone-number login.
- Manual export of full data (JSON/CSV).
- Low data usage: sync payloads are deltas; receipt images compressed and uploaded on Wi-Fi only (configurable).

---

### F13. Export & Share
- Export reports to **PDF** and **Excel/CSV**.
- Share via WhatsApp/Messenger/SMS as image or PDF (driver statement, daily summary, monthly P&L).
- Print-friendly monthly khata page (for banks/loan applications — proof of income).
- Bangla-capable PDF fonts.

---

### F14. Driver Companion Access (P2)
Owner invites a driver by phone number; the driver gets a restricted view.

| Capability | Owner | Driver |
|---|---|---|
| Add trips / day logs / expenses | ✅ | ✅ (pending owner approval, configurable) |
| See own earnings, advances, jama due | ✅ | ✅ |
| See other drivers / vehicle profit | ✅ | ❌ |
| Edit/delete past entries | ✅ | ❌ (can request) |
| Approve driver-submitted entries | ✅ | — |

- Entries from drivers are tagged and appear in an *Approval queue*.
- Both parties see the same driver balance → fewer disputes.

---

### F15. Clients & Routes (Truck/Pickup)
- **Clients:** name, phone, address, default rate, outstanding balance.
- **Saved routes:** from–to, typical distance, typical fare, typical toll.
- Auto-suggest fare and toll when a saved route is chosen.
- Client statement and receivable tracking (feeds F10).
- Advance received before trip and balance after delivery.

---

### F16. Notifications & Reminders
| Trigger | Message |
|---|---|
| End of day (configurable time) | "Aaj-er hisab dilen?" — log today's income if none entered |
| Jama due time | "Collect jama from {driver}" |
| Unpaid dues > N days | Aging nudge |
| Document / service expiring | 30/7/1-day reminders |
| Driver submits entry | Approval request |
| Weekly summary (Sat/Sun) | Profit recap per vehicle |

All local notifications work offline; user can set quiet hours.

---

### F17. Settings, Security & Monetization
- Language, numeral style, currency format (৳ 1,23,456 lakh/crore grouping option).
- App lock (PIN/biometric).
- Default categories and units (litre / m³ / kg / ton).
- Profit view: cash vs. accrual; include/exclude amortized fixed costs.
- Data export / account deletion.
- **Pricing (proposal):** Free = 1 vehicle, basic reports. Paid (monthly/yearly) = unlimited vehicles, driver access, jama module, PDF/Excel exports, backup history. Payment via bKash/Nagad/Play Store billing.

---

## 6. Key User Flows

### 6.1 CNG owner-driver: daily close
1. Open app → **Today** card.
2. Tap **+ Income**, type ৳2,800 → save.
3. Tap **⛽ Gas**, type ৳600 → save.
4. Dashboard shows *Profit today ৳2,200*.

### 6.2 Truck owner: trip with advance
1. **+ Trip** → vehicle, route (saved "Dhaka → Chattogram"), fare ৳18,000.
2. Client paid ৳8,000 advance → payment status *Partial*.
3. Add expenses: diesel ৳5,500, tolls ৳900, helper ৳700, driver ৳1,500.
4. Trip profit shown: ৳9,400. Receivable ৳10,000 appears in Dues.
5. On delivery, record client payment ৳10,000 → due cleared.

### 6.3 Jama owner: daily collection
1. Evening notification: "Collect jama: Rahim ৳600".
2. Open → tap **Collect** → Rahim paid ৳400 → mark *Partial*.
3. ৳200 added to Rahim's baki; calendar day turns yellow.
4. Next day Rahim pays ৳800 → allocation: ৳600 today + ৳200 old baki.

### 6.4 Owner with salaried driver: month-end
1. Open **Driver → Karim → Statement**.
2. See: salary ৳15,000 − advances ৳4,000 − paid ৳5,000 = **due ৳6,000**.
3. Record payout → share receipt via WhatsApp.

---

## 7. Data Model (Logical)

```
User(id, phone, name, role, language, created_at)
Vehicle(id, owner_id, nickname, type, reg_no, fuel_type, business_model, status, ...)
Driver(id, owner_id, name, phone, license_no, license_expiry, status, ...)
Assignment(id, vehicle_id, driver_id, pay_model, pay_params_json, start_date, end_date)
Trip(id, vehicle_id, driver_id, client_id?, route_id?, started_at, from, to, distance_km,
     fare, received_amount, driver_pay, notes, status)
DayLog(id, vehicle_id, driver_id, date, total_collection, km?, hours?, notes)
Expense(id, vehicle_id, trip_id?, daylog_id?, category_id, amount, paid_by, reimbursable,
        date, receipt_url?, litres?, odometer?)
JamaEntry(id, assignment_id, due_date, expected_amount, paid_amount, status, waived_reason?)
LedgerEntry(id, party_type, party_id, direction, amount, ref_type, ref_id, date, note)
Payment(id, party_type, party_id, amount, method_label, date, allocations_json)
Attendance(id, driver_id, date, status)
Advance(id, driver_id, amount, date, settled_in_payout_id?)
Payout(id, driver_id, period_start, period_end, gross, deductions, net, paid_at)
Client(id, owner_id, name, phone, address)
Route(id, owner_id, from, to, distance_km, default_fare, default_toll)
Document(id, vehicle_id|driver_id, type, number, expiry, image_url)
ServiceReminder(id, vehicle_id, type, due_km?, due_date?, last_done)
AuditLog(id, entity, entity_id, user_id, action, diff_json, at)
```

**Conventions:** UUID primary keys (client-generated for offline), `updated_at` + `deleted_at` (soft delete) for sync, money as integer poisha.

---

## 8. Non-Functional Requirements

| Area | Requirement |
|---|---|
| **Performance** | Cold start < 3 s on low-end Android (2 GB RAM); entry save < 200 ms |
| **Offline** | 100% of core flows work offline; sync resumes automatically |
| **Size** | APK/AAB < 30 MB; works on Android 8+ |
| **Usability** | Bangla-first, large touch targets (≥ 48 dp), numeric keypad for amounts, icon-led navigation, minimal typing |
| **Accessibility** | Scalable fonts, high contrast, screen-reader labels |
| **Security** | Phone OTP auth, TLS in transit, encrypted local DB, app lock, per-owner data isolation |
| **Privacy** | Collect minimum PII; NID optional; account/data deletion on request |
| **Reliability** | No data loss on crash/kill; writes are transactional; daily auto-backup |
| **Data accuracy** | Integer money math; profit engine unit-tested with edge cases |
| **Analytics** | Privacy-respecting usage analytics (opt-out); crash reporting |

---

## 9. Suggested Tech Stack (Non-binding)

- **App:** Flutter (single codebase, good low-end Android performance, strong Bangla font support) — or React Native.
- **Local DB:** SQLite (Drift / WatermelonDB).
- **Backend:** Supabase/Firebase or Node + PostgreSQL; REST/GraphQL with delta sync.
- **Auth:** Phone OTP (Firebase Auth / local SMS gateway such as SSL Wireless, BulkSMSBD).
- **Storage:** S3-compatible bucket for receipts/documents.
- **Reports:** On-device PDF generation with embedded Bangla font (e.g., Noto Sans Bengali).
- **Notifications:** Local scheduled notifications + FCM push.

---

## 10. Release Plan

### MVP (v1.0) — "Know my profit"
F1, F2, F3, F4, F5 (core), F6 (basic salary/daily/commission + advances), F8, F9 (daily/monthly), F12 (offline + backup), basic F13 (PDF share).

### v1.1 — "Jama & dues"
F7 Jama module, F10 Dues ledger, F16 reminders, F11 document reminders.

### v1.2 — "Trucks & teams"
F15 clients/routes, F14 driver companion, F13 Excel export, mileage analytics, F11 service schedule.

### v2.0 — "Growth"
Multi-user (manager/partner roles), bKash/Nagad payment links, loan-ready income certificate, fleet benchmarking, fuel-price tracker, iOS release.

---

## 11. Success Metrics

| Metric | Target (6 months post-launch) |
|---|---|
| Activation: first trip/day log within 24 h of install | ≥ 60% |
| Weekly active owners logging ≥ 3 days/week | ≥ 40% of installs |
| Median time to log an entry | ≤ 15 s |
| Day-30 retention | ≥ 35% |
| Free → paid conversion | ≥ 5% |
| Crash-free sessions | ≥ 99.5% |

---

## 12. Risks & Open Questions

| # | Risk / Question | Mitigation / Next step |
|---|---|---|
| 1 | Users are low-literacy and distrust apps with money data | Bangla voice hints, icon UI, local-only mode, trust messaging, user interviews with CNG/truck owners |
| 2 | Daily logging habit fades | End-of-day nudge, streaks, weekly profit summary, minimal-tap entry |
| 3 | Driver–owner disputes over data | Dual-view balances, approval queue, audit log |
| 4 | Informal expenses (police, tolls without receipts) | Allow category without receipt; chip shortcuts |
| 5 | Low-end devices / patchy connectivity | Offline-first, small APK, lazy image upload |
| 6 | Voice input in Bangla for entering amounts? | Evaluate in v1.2 (speech-to-text for amount + category) |
| 7 | Should gas (CNG) pricing/fuel-price defaults be built in? | Research BPC/Petrobangla published prices; user-editable |
| 8 | Legal: storing NID / driver data | Make optional; review local data-protection requirements |
| 9 | Is accrual view needed at v1 or cash-only? | Validate with user interviews; default cash |
| 10 | Pricing willingness in this segment | Test with free tier + yearly discount; consider ad-free promise |

---

## 13. Appendix — Sample Calculations

**CNG day (owner-driver):** Collection ৳2,800 − Gas ৳600 − Other ৳100 = **৳2,100 profit**.

**Jama vehicle (month):** Jama ৳600 × 26 days = ৳15,600 collected − Repairs ৳2,400 − EMI ৳5,000 = **৳8,200 owner net**.

**Pickup trip:** Fare ৳4,500 − Fuel ৳900 − Toll ৳200 − Helper ৳300 − Driver (20% commission) ৳900 = **৳2,200 trip profit**.

**Salaried driver balance:** Salary ৳15,000 − Advances ৳4,000 − Paid ৳5,000 = **৳6,000 owed**.
