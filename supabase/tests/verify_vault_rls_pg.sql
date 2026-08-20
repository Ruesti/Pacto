-- ============================================================================
-- Stufe 1 / Phase 1 — RLS-Verifikation gegen ein nacktes Postgres.
--
-- Beweist die vier im BRIEF_PACTO_FIX.md geforderten Testfaelle OHNE die volle
-- Supabase-/Docker-Umgebung: der Supabase-Auth-Kontext (auth.uid(), Rollen
-- anon/authenticated) wird minimal nachgebaut, dann wird die ECHTE Migration
-- 20260820120000_vault_rls_userid.sql per \i eingespielt und geprueft.
--
-- Aufruf aus dem Projektwurzelverzeichnis (wo supabase/ liegt):
--   psql -v ON_ERROR_STOP=1 -f supabase/tests/verify_vault_rls_pg.sql <db>
--
-- Jeder verletzte Sicherheits-Invariant wirft eine Exception -> psql bricht mit
-- Exit-Code != 0 ab. "Alle Assertions gruen" am Ende = bestanden.
-- ============================================================================
\set ON_ERROR_STOP on
begin;

-- --- Supabase-Auth-Kontext nachbauen ---------------------------------------
create schema if not exists auth;
create table if not exists auth.users (id uuid primary key);
-- auth.uid() wie in Supabase: liest den 'sub'-Claim; robust gegen leer/unset.
create or replace function auth.uid() returns uuid language sql stable as $$
  select nullif(nullif(current_setting('request.jwt.claims', true), '')::json->>'sub', '')::uuid
$$;
do $$ begin
  if not exists (select from pg_roles where rolname = 'anon') then create role anon nologin; end if;
  if not exists (select from pg_roles where rolname = 'authenticated') then create role authenticated nologin; end if;
end $$;
grant usage on schema public to anon, authenticated;
grant usage on schema auth to anon, authenticated;
grant execute on function auth.uid() to anon, authenticated;

-- --- Tabellen + alte (offene) Policies wie im Bestand ----------------------
create table public.sync_data (
  device_id uuid primary key, encrypted_payload text not null,
  updated_at timestamptz not null default now());
alter table public.sync_data enable row level security;
create policy "sync_data anon select" on public.sync_data for select to anon, authenticated using (true);
create policy "sync_data anon insert" on public.sync_data for insert to anon, authenticated with check (true);
create policy "sync_data anon update" on public.sync_data for update to anon, authenticated using (true) with check (true);

create table public.heartbeats (
  device_id uuid primary key, confirmed_at timestamptz not null default now());
alter table public.heartbeats enable row level security;
create policy "heartbeats anon select" on public.heartbeats for select to anon, authenticated using (true);
create policy "heartbeats anon insert" on public.heartbeats for insert to anon, authenticated with check (true);
create policy "heartbeats anon update" on public.heartbeats for update to anon, authenticated using (true) with check (true);

create table public.vault_settings (
  device_id uuid primary key, owner_name text, owner_email text not null,
  interval_days integer not null default 90, enabled boolean not null default false,
  confirmed_at timestamptz not null default now(), warning_sent_at timestamptz,
  heir_notified_at timestamptz, updated_at timestamptz not null default now());
alter table public.vault_settings enable row level security;
create policy "vault_settings anon all" on public.vault_settings for all to anon, authenticated using (true) with check (true);

create table public.vault_payloads (
  id uuid primary key default gen_random_uuid(), device_id uuid not null,
  heir_id uuid not null, heir_name text not null, heir_email text not null,
  policy text not null check (policy in ('none','komfort','maximum')),
  body text not null, pdf_b64 text, updated_at timestamptz not null default now(),
  unique (device_id, heir_id));
alter table public.vault_payloads enable row level security;
create policy "vault_payloads anon all" on public.vault_payloads for all to anon, authenticated using (true) with check (true);

-- Supabase-Baseline: beide Rollen bekommen Tabellenrechte (die Migration
-- entzieht sie anschliessend der anon-Rolle).
grant select, insert, update, delete
  on public.sync_data, public.heartbeats, public.vault_settings, public.vault_payloads
  to anon, authenticated;

-- === Die zu pruefenden Migrationen ========================================
\i supabase/migrations/20260820120000_vault_rls_userid.sql
\i supabase/migrations/20260820130000_vault_reset_tokens.sql

-- --- Zwei Nutzer -----------------------------------------------------------
\set uidA '00000000-0000-0000-0000-00000000000a'
\set uidB '00000000-0000-0000-0000-00000000000b'
\set devA '11111111-1111-1111-1111-111111111111'
\set heirA '22222222-2222-2222-2222-222222222222'
insert into auth.users(id) values (:'uidA'), (:'uidB');

-- --- A legt eigene Daten an (user_id per default auth.uid()) ----------------
set role authenticated;
select set_config('request.jwt.claims', json_build_object('sub', :'uidA')::text, true);
insert into public.vault_payloads(device_id, heir_id, heir_name, heir_email, policy, body)
  values (:'devA', :'heirA', 'Erbe', 'a-heir@example.com', 'komfort', 'geheim');
insert into public.vault_settings(device_id, owner_email)
  values (:'devA', 'a-owner@example.com');

-- --- Positivprobe: A sieht die eigene Zeile --------------------------------
do $$ declare n int; begin
  select count(*) into n from public.vault_payloads;
  if n <> 1 then raise exception 'POSITIV ROT: A sieht % statt 1 eigener Zeile', n; end if;
  raise notice 'OK  positiv  — A sieht % eigene Zeile', n;
end $$;

-- === TC1: Geraet B liest -> muss leer sein =================================
select set_config('request.jwt.claims', json_build_object('sub', :'uidB')::text, true);
do $$ declare n int; begin
  select count(*) into n from public.vault_payloads;
  if n <> 0 then raise exception 'TC1 ROT: B sieht % Fremdzeilen', n; end if;
  raise notice 'OK  TC1      — B sieht 0 Zeilen';
end $$;

-- === TC2: reiner anon-Key ohne Session -> 0 Zeilen oder permission denied ==
reset role; set role anon;
select set_config('request.jwt.claims', '', true);
do $$ declare n int; begin
  begin
    select count(*) into n from public.vault_payloads;
  exception when insufficient_privilege then
    raise notice 'OK  TC2      — anon: permission denied (kein Tabellenrecht)';
    return;
  end;
  if n <> 0 then raise exception 'TC2 ROT: anon sieht % Zeilen', n; end if;
  raise notice 'OK  TC2      — anon sieht 0 Zeilen';
end $$;

-- === TC3: B ueberschreibt A's heir_email -> muss scheitern =================
reset role; set role authenticated;
select set_config('request.jwt.claims', json_build_object('sub', :'uidB')::text, true);
do $$ declare c int; begin
  update public.vault_payloads set heir_email = 'attacker@evil.com'
    where heir_email = 'a-heir@example.com';
  get diagnostics c = row_count;
  if c <> 0 then raise exception 'TC3 ROT: B hat % Zeilen ueberschrieben', c; end if;
  raise notice 'OK  TC3 (1/2) — B aendert 0 Zeilen';
end $$;
select set_config('request.jwt.claims', json_build_object('sub', :'uidA')::text, true);
do $$ declare v text; begin
  select heir_email into v from public.vault_payloads limit 1;
  if v is distinct from 'a-heir@example.com' then raise exception 'TC3 ROT: heir_email ist jetzt %', v; end if;
  raise notice 'OK  TC3 (2/2) — A heir_email unveraendert (%)', v;
end $$;

-- === TC4: B setzt A's confirmed_at -> muss scheitern =======================
select set_config('request.jwt.claims', json_build_object('sub', :'uidB')::text, true);
do $$ declare c int; begin
  update public.vault_settings set confirmed_at = timestamptz '2000-01-01 00:00:00Z'
    where device_id = '11111111-1111-1111-1111-111111111111';
  get diagnostics c = row_count;
  if c <> 0 then raise exception 'TC4 ROT: B hat % vault_settings geaendert', c; end if;
  raise notice 'OK  TC4      — B aendert 0 vault_settings';
end $$;

-- === TC5: Loeschpfad (Phase 2, deleteAllServerData) ========================
-- B darf A's Zeile nicht loeschen ...
select set_config('request.jwt.claims', json_build_object('sub', :'uidB')::text, true);
do $$ declare c int; begin
  delete from public.vault_payloads where heir_email = 'a-heir@example.com';
  get diagnostics c = row_count;
  if c <> 0 then raise exception 'TC5 ROT: B hat % Fremdzeilen geloescht', c; end if;
  raise notice 'OK  TC5 (1/2) — B loescht 0 Fremdzeilen';
end $$;
-- ... A darf die eigene Zeile loeschen (RLS begrenzt auf eigene).
select set_config('request.jwt.claims', json_build_object('sub', :'uidA')::text, true);
do $$ declare c int; begin
  delete from public.vault_payloads;
  get diagnostics c = row_count;
  if c <> 1 then raise exception 'TC5 ROT: A konnte eigene Zeile nicht loeschen (rows=%)', c; end if;
  raise notice 'OK  TC5 (2/2) — A loescht die eigene Zeile';
end $$;

-- === TC6: vault_reset_tokens ist Service-Role-only (Phase 3) ===============
reset role; -- Superuser (umgeht RLS) legt ein Token an.
insert into public.vault_reset_tokens(token_hash, device_id, expires_at)
  values ('deadbeef', :'devA', now() + interval '1 day');
set role authenticated;
select set_config('request.jwt.claims', json_build_object('sub', :'uidA')::text, true);
do $$ declare n int; begin
  begin
    select count(*) into n from public.vault_reset_tokens;
  exception when insufficient_privilege then
    raise notice 'OK  TC6      — authenticated: kein Zugriff auf vault_reset_tokens';
    return;
  end;
  if n <> 0 then raise exception 'TC6 ROT: authenticated sieht % Token', n; end if;
  raise notice 'OK  TC6      — authenticated sieht 0 Token';
end $$;

reset role;
select 'Alle Assertions gruen — Phase 1 RLS + Phase 2 Loeschpfad + Phase 3 Token bestanden.' as ergebnis;
rollback;
