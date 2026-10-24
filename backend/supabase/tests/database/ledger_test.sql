-- pgTAP: run with `supabase test db`. NOT RUN yet (no database was available).
begin;
select plan(6);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000000c1', '+8801733333333');

set local role authenticated;
select set_config('request.jwt.claims',
  json_build_object('sub', '00000000-0000-0000-0000-0000000000c1', 'role', 'authenticated')::text, true);

-- A new ledger row is accepted.
select is(
  (public.sync_push('[{"t":"ledger_entries","row":{"id":"lg:trip:t1:0","created_at":1,"updated_at":1,
    "rev":0,"party_type":"customer","party_id":"","ref_type":"trip","ref_id":"t1","kind":"accrual",
    "amount_minor":100000,"occurred_day":20000}}]'::jsonb) -> 0 ->> 'status'),
  'accepted', 'a new ledger row is accepted');

-- Pushing the identical row again is harmless and changes nothing.
select is(
  (public.sync_push('[{"t":"ledger_entries","row":{"id":"lg:trip:t1:0","created_at":1,"updated_at":1,
    "rev":0,"party_type":"customer","party_id":"","ref_type":"trip","ref_id":"t1","kind":"accrual",
    "amount_minor":100000,"occurred_day":20000}}]'::jsonb) -> 0 ->> 'status'),
  'accepted', 'an identical re-push is accepted');
select is((select count(*)::int from public.ledger_entries), 1, 'still one row');

-- Changing an existing row is refused (reported as rejected).
select is(
  (public.sync_push('[{"t":"ledger_entries","row":{"id":"lg:trip:t1:0","created_at":1,"updated_at":2,
    "rev":1,"party_type":"customer","party_id":"","ref_type":"trip","ref_id":"t1","kind":"accrual",
    "amount_minor":1,"occurred_day":20000}}]'::jsonb) -> 0 ->> 'status'),
  'rejected', 'a changed ledger row is rejected');
select is((select amount_minor from public.ledger_entries where id = 'lg:trip:t1:0'), 100000::bigint,
  'the amount is unchanged');

-- Clients have no delete policy, so a delete removes nothing.
delete from public.ledger_entries where id = 'lg:trip:t1:0';
select is((select count(*)::int from public.ledger_entries), 1, 'a client delete removes nothing');

select * from finish();
rollback;
