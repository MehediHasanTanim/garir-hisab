# Sprint 7 — Status (partial)

Companion to [sprint-implementation-plan.md](sprint-implementation-plan.md) (Sprint 7: MVP hardening and beta). **This sprint is only partly done.** Most of it needs real devices and real owners, which were not available.

## Built

| ID | Result |
|---|---|
| S7-T2 | **Export my data** (More): one zip with a JSON copy and a CSV per table that has rows. Amounts are in poisha; the CSVs carry a byte-order mark so Excel reads Bangla. Drivers' national ID numbers, owner ids and sync flags are left out. Shared through the system share sheet. |
| S7-T1 | **Driver statement PDF** (driver ⋮ menu → Statement): pick this month, last month, last 3 months or all time; preview; share as PDF. Lists payouts (earned, bonus/penalty, advances recovered, paid), advances given, total paid and advances still owed. The statement is drawn by Flutter and embedded as an image in A4 pages (several pages if long), because the `pdf` package cannot shape Bangla conjuncts. |

New dependencies: `share_plus`, `archive`. New reads: `PayoutService.listForDriver`, `AdvanceRepository.listForDriver` (Future versions of the existing streams).

## Not done

- **S7-T3** Settings: language, numerals, grouping and profit view already existed; the "units" option was not added.
- **S7-T4** Performance pass on a low-end device: needs a device.
- **S7-T5** Accessibility pass (TalkBack labels, contrast): not started. Only the existing 200% text tests cover the new pages (not the statement page).
- **S7-T6** Integration tests for onboarding → trip → report and offline → sync: not started (sync fault tests from Sprint 6 exist at unit level).
- **S7-T7** Analytics (opt-out) and crash dashboards: not started. Sentry is already optional via `SENTRY_DSN`.
- **S7-T8** Play Store listing, privacy policy, data-safety form: not started.
- **S7-T9** Closed beta with real owners, **S7-T10** bug bash: need people and devices.
- **S7-T11** Upgrade dry-run: migration tests cover every step v1 → v6, but not an upgrade from a real earlier build.

## Limits

- The statement was checked in widget tests with a fake share sheet only; the Bangla rendering of the PDF and the real share to WhatsApp are unchecked on a device.
- Bangla strings are my translations and need native-speaker review.
- The Sprint 6 server SQL is still unrun (see sprint-6-status.md).

## Testing notes

- Widget tests that seed data through the container should `await` repositories directly; wrapping the seeding in `tester.runAsync` hung the test.
- Capturing a `RepaintBoundary` as an image works in widget tests when real time is allowed to pass (`runAsync` delays between pumps), but is slow (about 8 s for the statement test on this Mac).

## Checks run

- `flutter analyze`: no issues.
- Full `flutter test` run: 598 passed, 1 failed (the statement share test, because its fake share sheet override had been lost in an edit). After fixing that test, the statement file passes on its own (6 tests); the full suite was not run again.
- No release APK was built for this sprint's changes.
