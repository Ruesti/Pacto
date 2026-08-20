-- Stufe 2 / Phase 6 — zuverlaessiger Versand.
--
-- Problem (Befund 2-D): vault-trigger setzte heir_notified_at unabhaengig vom
-- Zustellerfolg und verhinderte danach jeden weiteren Versuch. Ein einziger
-- fehlgeschlagener Mailversand liess die Erben dauerhaft uninformiert.
--
-- Loesung: Zustellung pro Erbe verfolgen, nur bei vollstaendigem Erfolg
-- "erledigt" markieren, sonst am naechsten Cron-Tag erneut versuchen und nach
-- mehreren Fehlversuchen den Owner informieren.

-- Pro Erben-Brief: Zeitpunkt der erfolgreichen Zustellung (null = offen).
alter table public.vault_payloads
  add column if not exists sent_at timestamptz;

-- Pro Geraet: Zahl der Zustellversuche + einmaliger Owner-Alarm.
alter table public.vault_settings
  add column if not exists notify_attempts integer not null default 0;
alter table public.vault_settings
  add column if not exists owner_alerted_at timestamptz;
