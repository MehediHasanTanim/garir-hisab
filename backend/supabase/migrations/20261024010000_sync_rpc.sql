-- Sync RPCs. Both run as the calling user (security invoker), so row-level
-- security is what keeps one owner's data from another's.

-- Pushes a batch of rows.
--
--   sync_push('[{"t": "trips", "row": {"id": "...", "updated_at": 1, ...}}]')
--
-- Returns one result per input, in order:
--   {"id", "t", "status": "accepted"}                       row stored
--   {"id", "t", "status": "conflict", "row": {...}}          the server's copy is newer
--   {"id", "t", "status": "rejected", "reason": "..."}       the row is invalid
--
-- Pushing the same row again is harmless (idempotent): last write wins by
-- `updated_at`, and an equal timestamp is accepted.
create or replace function public.sync_push(rows jsonb) returns jsonb
language plpgsql as $$
declare
  item jsonb;
  tname text;
  doc jsonb;
  existing jsonb;
  cols text;
  out jsonb := '[]'::jsonb;
  allowed text[] := public.sync_tables();
begin
  if auth.uid() is null then
    raise exception 'not signed in' using errcode = '28000';
  end if;
  if jsonb_typeof(rows) <> 'array' then
    raise exception 'rows must be a JSON array' using errcode = '22023';
  end if;
  if jsonb_array_length(rows) > 500 then
    raise exception 'too many rows in one push' using errcode = '22023';
  end if;

  for item in select * from jsonb_array_elements(rows) loop
    tname := item ->> 't';
    doc := item -> 'row';
    begin
      if tname is null or not (tname = any (allowed)) then
        out := out || jsonb_build_object(
          'id', doc ->> 'id', 't', tname,
          'status', 'rejected', 'reason', 'unknown table');
        continue;
      end if;
      if doc is null or doc ->> 'id' is null or doc ->> 'updated_at' is null then
        out := out || jsonb_build_object(
          'id', doc ->> 'id', 't', tname,
          'status', 'rejected', 'reason', 'id and updated_at are required');
        continue;
      end if;

      -- The owner is always the caller, whatever the phone says.
      doc := (doc - 'dirty' - 'server_seq') || jsonb_build_object('owner_id', auth.uid());

      execute format('select to_jsonb(t) from public.%I t where id = $1', tname)
        into existing using doc ->> 'id';

      if existing is not null
         and (existing ->> 'updated_at')::bigint > (doc ->> 'updated_at')::bigint then
        out := out || jsonb_build_object(
          'id', doc ->> 'id', 't', tname, 'status', 'conflict', 'row', existing);
        continue;
      end if;

      select string_agg(format('%1$I = excluded.%1$I', column_name), ', ')
        into cols
        from information_schema.columns
        where table_schema = 'public' and table_name = tname
          and column_name not in ('id', 'owner_id', 'server_seq');

      execute format(
        'insert into public.%1$I select * from jsonb_populate_record(null::public.%1$I, $1) '
        'on conflict (id) do update set %2$s',
        tname, cols
      ) using doc;

      out := out || jsonb_build_object('id', doc ->> 'id', 't', tname, 'status', 'accepted');
    exception when others then
      out := out || jsonb_build_object(
        'id', doc ->> 'id', 't', tname, 'status', 'rejected', 'reason', sqlerrm);
    end;
  end loop;
  return out;
end;
$$;

-- Pulls rows changed after the cursor `since`, oldest change first.
--
--   sync_pull(0, 500) -> {"rows": [{"t": "trips", "seq": 7, "row": {...}}],
--                          "cursor": 7, "has_more": false}
--
-- Deleted rows come back as ordinary rows with `deleted_at` set.
create or replace function public.sync_pull(since bigint, lim int default 500)
returns jsonb
language plpgsql as $$
declare
  allowed text[] := public.sync_tables();
  sql text;
  result jsonb;
  capped int := least(greatest(lim, 1), 1000);
begin
  if auth.uid() is null then
    raise exception 'not signed in' using errcode = '28000';
  end if;

  select string_agg(
           format('select %L::text as t, server_seq as seq, to_jsonb(x) as row from public.%I x where server_seq > $1', n, n),
           ' union all ')
    into sql
    from unnest(allowed) as n;

  execute format(
    'with page as (select * from (%s) u order by seq limit %s) '
    'select jsonb_build_object('
    '  ''rows'', coalesce((select jsonb_agg(jsonb_build_object(''t'', t, ''seq'', seq, ''row'', row) order by seq) '
    '                     from (select * from page limit %s) p), ''[]''::jsonb), '
    '  ''cursor'', coalesce((select max(seq) from (select seq from page order by seq limit %s) q), $1), '
    '  ''has_more'', (select count(*) from page) > %s)',
    sql, capped + 1, capped, capped, capped
  ) into result using since;
  return result;
end;
$$;

grant execute on function public.sync_push(jsonb) to authenticated;
grant execute on function public.sync_pull(bigint, int) to authenticated;
revoke execute on function public.sync_push(jsonb) from anon, public;
revoke execute on function public.sync_pull(bigint, int) from anon, public;
