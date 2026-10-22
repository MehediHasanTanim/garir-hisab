# ADR-0003: Supabase backend

- **Status:** Accepted
- **Date:** 2026-10-22

## Context
We need auth (phone OTP), Postgres with row-level security, storage and edge functions with minimal ops.

## Decision
Use Supabase (dev, staging, prod projects) with migrations in `backend/supabase/migrations`.

## Consequences
Low ops, SQL reporting, RLS tenant isolation. Vendor coupling; Postgres keeps an exit path. Alternatives: Firebase (weak SQL), custom Node API (more ops).
