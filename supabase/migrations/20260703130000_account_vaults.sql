-- account_vaults — optionales, Account-gebundenes Voll-Backup fuer Recovery.
-- Getrennt von sync_data (anonym, device_id-basiert), das unveraendert bestehen
-- bleibt. Der echte AES-256-Sync-Key wird zusaetzlich mit einem aus dem
-- Account-Passwort abgeleiteten Schluessel verschluesselt mitgesichert
-- (key_salt + encrypted_key) — siehe crypto_service.dart.
create table if not exists public.account_vaults (
  user_id           uuid        primary key references auth.users(id) on delete cascade,
  encrypted_payload text        not null,
  key_salt          text        not null,
  encrypted_key     text        not null,
  updated_at        timestamptz not null default now()
);

alter table public.account_vaults enable row level security;

create policy "account_vaults own select" on public.account_vaults
  for select to authenticated using (auth.uid() = user_id);
create policy "account_vaults own insert" on public.account_vaults
  for insert to authenticated with check (auth.uid() = user_id);
create policy "account_vaults own update" on public.account_vaults
  for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
