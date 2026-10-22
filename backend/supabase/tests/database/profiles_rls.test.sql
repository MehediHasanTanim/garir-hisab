-- pgTAP: run with `supabase test db`.
begin;
select plan(7);

-- Two users.
insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000000a1', '+8801711111111'),
  ('00000000-0000-0000-0000-0000000000a2', '+8801722222222');

select is(
  (select count(*)::int from public.profiles),
  2,
  'profile rows are created automatically for new users'
);

-- Act as user A.
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);

select is(
  (select count(*)::int from public.profiles),
  1,
  'user A sees only their own profile'
);

select is(
  (select phone from public.profiles),
  '+8801711111111',
  'user A sees their own phone'
);

update public.profiles set display_name = 'Rahim';
select is(
  (select display_name from public.profiles),
  'Rahim',
  'user A can update their own profile'
);

select is(
  (with u as (
     update public.profiles set display_name = 'hacked'
     where id = '00000000-0000-0000-0000-0000000000a2' returning 1)
   select count(*)::int from u),
  0,
  'user A cannot update user B'
);

select throws_ok(
  $$insert into public.profiles (id) values ('00000000-0000-0000-0000-0000000000a2')$$,
  null,
  null,
  'user A cannot insert a profile for another user'
);

select throws_ok(
  $$update public.profiles set role = 'admin'$$,
  '23514',
  null,
  'role must be owner or driver'
);

select * from finish();
rollback;
