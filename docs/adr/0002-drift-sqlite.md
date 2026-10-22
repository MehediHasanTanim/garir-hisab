# ADR-0002: Drift on encrypted SQLite

- **Status:** Accepted
- **Date:** 2026-10-22

## Context
The phone is the primary database; financial data must be encrypted at rest and queryable for reports.

## Decision
Use Drift over SQLite3 Multiple Ciphers (sqlite3 build hook `source: sqlite3mc`) with the key held in the Android Keystore. See spikes/encrypted-db.md.

## Consequences
Typed relational queries and migrations. Native-assets build hook must be verified on device (S0-T4). Alternatives rejected: Isar/Hive (weak relational reporting), plain SQLite (no encryption).
