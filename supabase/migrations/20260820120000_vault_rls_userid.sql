-- Stufe 1 / Phase 1 — Zugriffskontrolle.
--
-- Ersetzt das bisherige, gebrochene Vertrauensmodell "device_id wirkt als
-- Zugriffstoken" (das keine Policy je geprueft hat) durch echte Row Level
-- Security auf Basis der Supabase-Auth-Identitaet.
--
-- Identitaetsmodell (siehe BRIEF_PACTO_FIX.md §0.1, Option A):
--   * Jede Installation meldet sich anonym an (auth.users-Zeile, echte auth.uid).
--   * Jede der vier bisher offenen Tabellen bekommt eine user_id und wird per
--     `using ((select auth.uid()) = user_id)` auf den Eigentuemer eingeschraenkt.
--   * Der anon-Rolle (blosser anon-Key ohne Session) wird jeder Zugriff entzogen.
--   * Das bestehende Account-Feature (account_vaults, E-Mail/Passwort) ist die
--     optionale Upgrade-Schicht auf derselben auth.uid und bleibt unveraendert.
--
-- Diese Migration ERSETZT die alten `using (true)`-Policies, sie ergaenzt sie
-- nicht. Es gibt keine Bestandsdaten in der Produktivinstanz — Breaking Change
-- am Schema ist bewusst zulaessig (siehe Brief-Kopf).

-- Wrapper: (select auth.uid()) statt auth.uid() — Postgres cached den Aufruf
-- dann pro Query statt pro Zeile (Supabase-RLS-Performance-Empfehlung).

-- ===========================================================================
-- sync_data — verschluesseltes Voll-Backup pro Geraet
-- ===========================================================================
alter table public.sync_data
  add column if not exists user_id uuid not null default auth.uid()
    references auth.users(id) on delete cascade;

drop policy if exists "sync_data anon select" on public.sync_data;
drop policy if exists "sync_data anon insert" on public.sync_data;
drop policy if exists "sync_data anon update" on public.sync_data;

revoke all on public.sync_data from anon;

create policy "sync_data owner select" on public.sync_data
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "sync_data owner insert" on public.sync_data
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "sync_data owner update" on public.sync_data
  for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "sync_data owner delete" on public.sync_data
  for delete to authenticated using ((select auth.uid()) = user_id);

-- ===========================================================================
-- heartbeats — Lebenszeichen pro Geraet
-- ===========================================================================
alter table public.heartbeats
  add column if not exists user_id uuid not null default auth.uid()
    references auth.users(id) on delete cascade;

drop policy if exists "heartbeats anon select" on public.heartbeats;
drop policy if exists "heartbeats anon insert" on public.heartbeats;
drop policy if exists "heartbeats anon update" on public.heartbeats;

revoke all on public.heartbeats from anon;

create policy "heartbeats owner select" on public.heartbeats
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "heartbeats owner insert" on public.heartbeats
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "heartbeats owner update" on public.heartbeats
  for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "heartbeats owner delete" on public.heartbeats
  for delete to authenticated using ((select auth.uid()) = user_id);

-- ===========================================================================
-- vault_settings — Tresor-Einstellungen pro Geraet (owner_email, Intervall, ...)
-- ===========================================================================
alter table public.vault_settings
  add column if not exists user_id uuid not null default auth.uid()
    references auth.users(id) on delete cascade;

drop policy if exists "vault_settings anon all" on public.vault_settings;

revoke all on public.vault_settings from anon;

create policy "vault_settings owner select" on public.vault_settings
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "vault_settings owner insert" on public.vault_settings
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "vault_settings owner update" on public.vault_settings
  for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "vault_settings owner delete" on public.vault_settings
  for delete to authenticated using ((select auth.uid()) = user_id);

-- ===========================================================================
-- vault_payloads — fertig gerenderte, verschluesselte Erben-Briefe
-- ===========================================================================
alter table public.vault_payloads
  add column if not exists user_id uuid not null default auth.uid()
    references auth.users(id) on delete cascade;

drop policy if exists "vault_payloads anon all" on public.vault_payloads;

revoke all on public.vault_payloads from anon;

create index if not exists vault_payloads_user_id_idx
  on public.vault_payloads(user_id);

create policy "vault_payloads owner select" on public.vault_payloads
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "vault_payloads owner insert" on public.vault_payloads
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "vault_payloads owner update" on public.vault_payloads
  for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "vault_payloads owner delete" on public.vault_payloads
  for delete to authenticated using ((select auth.uid()) = user_id);
