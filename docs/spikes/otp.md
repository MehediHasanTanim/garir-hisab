# Spike S0-T6: Phone OTP (Supabase + BD SMS gateway)

## Status: not run
Needs external accounts and a real BD number, which this repo cannot provide:
a Supabase project, and an SMS provider account (SSL Wireless or BulkSMSBD).

## Plan
1. Create the Supabase dev project; enable Phone auth.
2. Supabase has no native BD gateway: use its Send SMS auth hook (HTTP) to an edge function that calls the BD provider's API.
3. Test end-to-end on 2+ BD operators (Grameenphone, Robi, Banglalink); record delivery time and failures.
4. Record cost per SMS and rate limits; evaluate a second provider for failover.

## Decision
**Pending** (blocked on provider accounts).
