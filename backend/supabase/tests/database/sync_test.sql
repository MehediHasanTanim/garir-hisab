-- pgTAP: run with `supabase test db`. NOT RUN in this repository's CI yet.
begin;
select plan(16);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000000b1', '+8801711111111'),
  ('00000000-0000-0000-0000-0000000000b2', '+8801722222222');

create or replace function pg_temp.as_user(uid text) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claims',
    json_build_object('sub', uid, 'role', 'authenticated')::text, true);
end;
$$;

set local role authenticated;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000b1');

-- Accepts a new row and forces the owner to the caller.
select is(
  (public.sync_push('[{"t":"vehicles","row":{"id":"v1","owner_id":"00000000-0000-0000-0000-0000000000b2",
    "created_at":1,"updated_at":10,"rev":0,"nickname":"Rahim","type":"cng","fuel_type":"cng",
    "business_model":"self","status":"active","archived":false}}]'::jsonb) -> 0 ->> 'status'),
  'accepted', 'a new row is accepted');
select is((select owner_id::text from public.vehicles where id = 'v1'),
  '00000000-0000-0000-0000-0000000000b1', 'the owner is the caller, not what the phone said');

-- Idempotent: the same row again changes nothing but is still accepted.
select is(
  (public.sync_push('[{"t":"vehicles","row":{"id":"v1","created_at":1,"updated_at":10,"rev":0,
    "nickname":"Rahim","type":"cng","fuel_type":"cng","business_model":"self","status":"active",
    "archived":false}}]'::jsonb) -> 0 ->> 'status'),
  'accepted', 'pushing the same row again is accepted');
select is((select count(*)::int from public.vehicles), 1, 'no duplicate row');

-- Last write wins by updated_at.
select is(
  (public.sync_push('[{"t":"vehicles","row":{"id":"v1","created_at":1,"updated_at":20,"rev":1,
    "nickname":"Newer","type":"cng","fuel_type":"cng","business_model":"self","status":"active",
    "archived":false}}]'::jsonb) -> 0 ->> 'status'),
  'accepted', 'a newer write is accepted');
select is(
  (public.sync_push('[{"t":"vehicles","row":{"id":"v1","created_at":1,"updated_at":15,"rev":1,
    "nickname":"Stale","type":"cng","fuel_type":"cng","business_model":"self","status":"active",
    "archived":false}}]'::jsonb) -> 0 ->> 'status'),
  'conflict', 'an older write is reported as a conflict');
select is((select nickname from public.vehicles where id = 'v1'), 'Newer', 'the newer data stays');

-- Invalid input is rejected per row, not for the whole batch.
select is(
  (public.sync_push('[{"t":"nope","row":{"id":"x","updated_at":1}},
    {"t":"vehicles","row":{"id":"v2","created_at":1,"updated_at":1,"rev":0,"nickname":"Two",
    "type":"cng","fuel_type":"cng","business_model":"self","status":"active","archived":false}}]'::jsonb) -> 0 ->> 'status'),
  'rejected', 'an unknown table is rejected');
select is((select count(*)::int from public.vehicles), 2, 'the valid row in the same batch still lands');

-- A phone clock far in the future is clamped.
select public.sync_push('[{"t":"vehicles","row":{"id":"v3","created_at":1,"updated_at":99999999999999,
  "rev":0,"nickname":"Future","type":"cng","fuel_type":"cng","business_model":"self",
  "status":"active","archived":false}}]'::jsonb);
select ok((select updated_at from public.vehicles where id = 'v3')
  < (extract(epoch from now()) * 1000)::bigint + 90000000, 'updated_at is clamped to one day ahead');

-- Pull: cursor and pagination.
select is((public.sync_pull(0, 2) ->> 'has_more')::boolean, true, 'a page of 2 of 3 has more');
select is(jsonb_array_length(public.sync_pull(0, 2) -> 'rows'), 2, 'the page has 2 rows');
select is(
  (public.sync_pull((public.sync_pull(0, 2) ->> 'cursor')::bigint, 2) -> 'rows' -> 0 ->> 'seq')::bigint
    > (public.sync_pull(0, 2) ->> 'cursor')::bigint, true, 'the next page continues after the cursor');

-- Another owner sees none of it and cannot overwrite it.
select pg_temp.as_user('00000000-0000-0000-0000-0000000000b2');
select is(jsonb_array_length(public.sync_pull(0, 100) -> 'rows'), 0, 'other owners see nothing');
select is(
  (public.sync_push('[{"t":"vehicles","row":{"id":"v1","created_at":1,"updated_at":99,"rev":9,
    "nickname":"Hijack","type":"cng","fuel_type":"cng","business_model":"self","status":"active",
    "archived":false}}]'::jsonb) -> 0 ->> 'status'),
  'rejected', 'another owner cannot take over an id');

-- Signed out: refused.
select set_config('request.jwt.claims', '{}', true);
select throws_ok($$select public.sync_pull(0, 10)$$, '28000', 'not signed in', 'sync requires sign-in');

select * from finish();
rollback;
