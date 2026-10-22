# Backend

Supabase project: migrations in `supabase/migrations`, edge functions in
`supabase/functions` (added from Sprint 6).

Environments: create three Supabase projects (dev, staging, prod). CI applies
migrations to **staging** on push to `main` using the secrets
`SUPABASE_ACCESS_TOKEN`, `SUPABASE_STAGING_DB_PASSWORD`,
`SUPABASE_STAGING_PROJECT_REF`. Prod migrations are applied manually.
