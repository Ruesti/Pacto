-- Pacto — initiales Datenbank-Schema
-- Drei Tabellen:
--   sync_data   — verschluesseltes Voll-Backup pro Geraet (Phase 9)
--   heartbeats  — Lebenszeichen fuer den Inaktivitaets-Tresor (Phase 9 / v1.1)
--   scan_counts — Rate-Limit der KI-Extraktion (Phase 6)

-- ===========================================================================
-- sync_data — verschluesseltes Voll-Backup pro Geraet
-- Der Payload wird in der App mit AES-256-GCM verschluesselt (crypto_service.dart).
-- Der Schluessel verlaesst das Geraet nie. Zugriff erfolgt mit dem anon key;
-- die zufaellige device_id (UUIDv4) wirkt faktisch als Zugriffstoken.
-- ===========================================================================
create table if not exists public.sync_data (
  device_id         uuid        primary key,
  encrypted_payload text        not null,
  updated_at        timestamptz not null default now()
);

alter table public.sync_data enable row level security;

create policy "sync_data anon select"
  on public.sync_data for select to anon, authenticated using (true);
create policy "sync_data anon insert"
  on public.sync_data for insert to anon, authenticated with check (true);
create policy "sync_data anon update"
  on public.sync_data for update to anon, authenticated using (true) with check (true);

-- ===========================================================================
-- heartbeats — Lebenszeichen fuer den Inaktivitaets-Tresor
-- Jedes Lebenszeichen setzt confirmed_at = now(). Die serverseitige
-- Tresor-Automatik (pg_cron + Edge Function) folgt in v1.1.
-- ===========================================================================
create table if not exists public.heartbeats (
  device_id    uuid        primary key,
  confirmed_at timestamptz not null default now()
);

alter table public.heartbeats enable row level security;

create policy "heartbeats anon select"
  on public.heartbeats for select to anon, authenticated using (true);
create policy "heartbeats anon insert"
  on public.heartbeats for insert to anon, authenticated with check (true);
create policy "heartbeats anon update"
  on public.heartbeats for update to anon, authenticated using (true) with check (true);

-- ===========================================================================
-- scan_counts — Rate-Limit der KI-Extraktion (max. 100 Scans pro User/Monat)
-- Zugriff ausschliesslich durch die Edge Function extract-contract, die mit
-- dem service_role key arbeitet und RLS damit umgeht. RLS ist aktiv, aber
-- es gibt bewusst KEINE Policy => anon/authenticated haben keinen Zugriff.
-- Primaerschluessel (user_id, month) erlaubt den Upsert per on_conflict.
-- ===========================================================================
create table if not exists public.scan_counts (
  user_id uuid    not null,
  month   text    not null,                  -- Format 'YYYY-MM'
  count   integer not null default 0,
  primary key (user_id, month)
);

alter table public.scan_counts enable row level security;
