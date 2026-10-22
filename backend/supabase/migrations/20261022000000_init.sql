-- S0-T7: baseline migration. Real schema starts in Sprint 2/6.
create table if not exists public.schema_info (
  id int primary key default 1 check (id = 1),
  created_at timestamptz not null default now()
);
insert into public.schema_info default values on conflict do nothing;
alter table public.schema_info enable row level security;
