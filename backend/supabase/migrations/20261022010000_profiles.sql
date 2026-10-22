-- S2-T1: user profiles and the tenant-isolation convention.
--
-- Convention for every later table: an `owner_id uuid` column referencing
-- auth.users, RLS enabled, and policies restricted to `owner_id = auth.uid()`.

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  phone text,
  display_name text,
  role text not null default 'owner' check (role in ('owner', 'driver')),
  language text not null default 'bn' check (language in ('bn', 'en')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy profiles_select_own on public.profiles
  for select to authenticated using (id = auth.uid());

create policy profiles_insert_own on public.profiles
  for insert to authenticated with check (id = auth.uid());

create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

-- No delete policy: profiles are removed only via auth.users cascade.

create or replace function public.set_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- Create the profile row automatically on sign-up.
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, phone) values (new.id, new.phone);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
