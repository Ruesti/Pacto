-- Stufe 1 / Phase 3 — Widerruf nach Deinstallation.
--
-- Problem (Befund Phase 3): Die Vorwarnung enthielt keinen Widerrufs-Link;
-- der einzige Weg zurueck war "App oeffnen" — nach einer Deinstallation
-- ausgeschlossen.
--
-- Loesung: Ein hochentropes Reset-Token wird beim Versand einer Vorwarnung
-- erzeugt, serverseitig NUR als SHA-256-Hash abgelegt, an genau eine
-- vault_settings-Zeile gebunden und mit Ablaufdatum versehen. Der Link in der
-- Mail traegt das Klartext-Token; die Edge Function vault-postpone hasht es,
-- schlaegt die Ausloesung auf (confirmed_at = now()) und loescht das Token.

-- --- Zwei Vorwarnungen statt einer ---------------------------------------
-- warning_count zaehlt die bereits versandten Vorwarnungen (0/1/2). Der
-- Trigger feuert erst, wenn mindestens zwei Vorwarnungen raus sind.
alter table public.vault_settings
  add column if not exists warning_count integer not null default 0;

-- --- Reset-Token-Tabelle --------------------------------------------------
-- Nur der Service-Role-Key (Edge Functions) greift zu: RLS ist an, es gibt
-- bewusst KEINE Policy => anon/authenticated haben keinen Zugriff. Das Token
-- selbst liegt nur als Hash vor; aus der Tabelle laesst sich der Klartext
-- nicht rekonstruieren.
create table if not exists public.vault_reset_tokens (
  token_hash text        primary key,             -- sha256(raw token), hex
  device_id  uuid        not null
    references public.vault_settings(device_id) on delete cascade,
  expires_at timestamptz not null,
  created_at timestamptz not null default now()
);

alter table public.vault_reset_tokens enable row level security;
-- bewusst keine Policy => nur service_role.

create index if not exists vault_reset_tokens_device_id_idx
  on public.vault_reset_tokens(device_id);
create index if not exists vault_reset_tokens_expires_at_idx
  on public.vault_reset_tokens(expires_at);

revoke all on public.vault_reset_tokens from anon, authenticated;
