-- Inaktivitaets-Tresor — Schema fuer die automatische Erbenbenachrichtigung.
--
-- Vertrauensmodell:
--   * device_id (UUID) wirkt als faktisches Zugriffstoken — analog zu
--     sync_data und heartbeats.
--   * Der Payload pro Erbe ist bereits in der App fertig gerendert und
--     verschluesselt; der Server haelt nur die Bytes und kennt das
--     Endgeraet nicht mehr, wenn er ihn versendet.
--   * Im Komfort-Modus liefert die App einen mit dem Pacto-Service-Key
--     wieder entschluesselbaren Envelope; im Maximum-Modus ist der
--     Envelope unter dem Erben-PIN verschluesselt — der Server liest
--     ihn nie.

-- ===========================================================================
-- vault_settings — Einstellungen pro Geraet
-- ===========================================================================
create table if not exists public.vault_settings (
  device_id         uuid        primary key,
  owner_name        text,
  owner_email       text        not null,
  interval_days     integer     not null default 90,
  enabled           boolean     not null default false,
  confirmed_at      timestamptz not null default now(),
  warning_sent_at   timestamptz,
  heir_notified_at  timestamptz,
  updated_at        timestamptz not null default now()
);

alter table public.vault_settings enable row level security;

create policy "vault_settings anon all"
  on public.vault_settings for all to anon, authenticated
  using (true) with check (true);

-- ===========================================================================
-- vault_payloads — fertig gerenderte, verschluesselte Erben-Briefe
-- Eine Zeile pro (device_id, heir_id). Der Server merged sie zur Mail.
-- ===========================================================================
create table if not exists public.vault_payloads (
  id          uuid        primary key default gen_random_uuid(),
  device_id   uuid        not null,
  heir_id     uuid        not null,
  heir_name   text        not null,
  heir_email  text        not null,
  policy      text        not null check (policy in ('none', 'komfort', 'maximum')),
  -- Klartext-Body wenn policy = komfort/none. Im Maximum-Modus enthaelt der
  -- body die Hinweise + bereits PIN-verschluesselte Cipher-Bloecke pro
  -- Vertrag, der Klartext liegt nirgends.
  body        text        not null,
  -- Fuer Komfort-Modus: optionaler PDF-Anhang (base64).
  pdf_b64     text,
  updated_at  timestamptz not null default now(),
  unique (device_id, heir_id)
);

alter table public.vault_payloads enable row level security;

create policy "vault_payloads anon all"
  on public.vault_payloads for all to anon, authenticated
  using (true) with check (true);

-- ===========================================================================
-- vault_log — Audit-Log der ausgeloesten Mails, damit der Trigger
-- nicht doppelt feuert.
-- ===========================================================================
create table if not exists public.vault_log (
  id          uuid        primary key default gen_random_uuid(),
  device_id   uuid        not null,
  event       text        not null,   -- 'warning' | 'heir_sent' | 'reset'
  message     text,
  created_at  timestamptz not null default now()
);

alter table public.vault_log enable row level security;
-- bewusst keine Policy => nur service_role darf lesen/schreiben.

-- ===========================================================================
-- pg_cron Trigger — taeglich 09:00 UTC die vault-trigger-Function aufrufen.
-- Voraussetzung: pg_cron + pg_net Extensions sind in Supabase verfuegbar.
-- Der Service-Role-Key wird als Vault-Secret verwaltet; die Funktion liest
-- ihn ueber den Header.
-- ===========================================================================
create extension if not exists pg_cron;
create extension if not exists pg_net;

do $$
declare
  proj_url text := current_setting('app.settings.project_url', true);
  svc_key  text := current_setting('app.settings.service_role_key', true);
begin
  if proj_url is null or svc_key is null then
    raise notice 'Skipping cron schedule — set app.settings.project_url and app.settings.service_role_key, then re-run this block.';
    return;
  end if;

  perform cron.unschedule('vault-daily') where exists (
    select 1 from cron.job where jobname = 'vault-daily'
  );

  perform cron.schedule(
    'vault-daily',
    '0 9 * * *',
    format($cron$
      select net.http_post(
        url := %L,
        headers := jsonb_build_object('Authorization', 'Bearer %s', 'Content-Type', 'application/json'),
        body := '{}'::jsonb
      );
    $cron$, proj_url || '/functions/v1/vault-trigger', svc_key)
  );
end $$;
