#!/usr/bin/env bash
# ============================================================================
# Stufe 1 / Phase 1 — Verifikation der Zugriffskontrolle (RLS).
#
# Prueft die vier im BRIEF_PACTO_FIX.md geforderten Testfaelle gegen eine
# LOKALE Supabase-Instanz (NIE gegen die Produktivinstanz):
#
#   1. Geraet A schreibt, Geraet B liest        -> B muss leer sehen.
#   2. select=* mit reinem anon-Key ohne Session -> 0 Zeilen oder 401/403.
#   3. Fremdes Ueberschreiben vault_payloads.heir_email -> muss scheitern.
#   4. Fremdes Setzen vault_settings.confirmed_at        -> muss scheitern.
#
# Voraussetzung: Docker laeuft und `supabase start` ist aktiv. Das Skript
# spielt die Migrationen frisch ein (`supabase db reset`) und testet dann.
#
# Aufruf (im Projektwurzelverzeichnis, wo supabase/ liegt):
#   bash supabase/tests/verify_vault_rls.sh
#
# Optional per Env ueberschreibbar: SUPABASE_URL, ANON_KEY.
# ============================================================================
set -uo pipefail

URL="${SUPABASE_URL:-http://127.0.0.1:54321}"
FAILED=0

note() { printf '\n\033[1m%s\033[0m\n' "$*"; }
pass() { printf '  \033[32mPASS\033[0m %s\n' "$*"; }
fail() { printf '  \033[31mFAIL\033[0m %s\n' "$*"; FAILED=1; }

# --- Anon-Key ermitteln --------------------------------------------------
if [ -z "${ANON_KEY:-}" ]; then
  if command -v supabase >/dev/null 2>&1; then
    ANON_KEY="$(supabase status 2>/dev/null | awk -F': *' '/anon key/{print $2; exit}')"
  fi
fi
if [ -z "${ANON_KEY:-}" ]; then
  echo "ANON_KEY nicht gefunden. Setze ANON_KEY=... (aus 'supabase status')."
  exit 2
fi

# --- Migrationen frisch einspielen --------------------------------------
if command -v supabase >/dev/null 2>&1; then
  note "supabase db reset (Migrationen frisch anwenden)"
  supabase db reset >/dev/null 2>&1 || { echo "db reset fehlgeschlagen — laeuft 'supabase start'?"; exit 2; }
fi

# --- Hilfen --------------------------------------------------------------
# Anonyme Session anlegen -> access_token ausgeben.
anon_session() {
  curl -s -X POST "$URL/auth/v1/signup" \
    -H "apikey: $ANON_KEY" -H "Content-Type: application/json" \
    -d '{"data":{},"gotrue_meta_security":{"captcha_token":null}}' \
  | grep -o '"access_token":"[^"]*"' | head -1 | cut -d'"' -f4
}
uid_of() { # token -> user id
  curl -s "$URL/auth/v1/user" -H "apikey: $ANON_KEY" -H "Authorization: Bearer $1" \
  | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4
}

note "Zwei anonyme Sessions anlegen"
TOK_A="$(anon_session)"; UID_A="$(uid_of "$TOK_A")"
TOK_B="$(anon_session)"; UID_B="$(uid_of "$TOK_B")"
[ -n "$TOK_A" ] && [ -n "$TOK_B" ] && [ "$UID_A" != "$UID_B" ] \
  && pass "Session A ($UID_A) und B ($UID_B) angelegt" \
  || { fail "Anonyme Sessions konnten nicht angelegt werden (anonymous sign-in aktiv?)"; exit 1; }

DEV_A="11111111-1111-1111-1111-111111111111"
HEIR_A="22222222-2222-2222-2222-222222222222"

# --- Testdaten von A anlegen (user_id per default auth.uid()) ------------
note "Geraet A legt vault_payloads + vault_settings an"
INS_PAY="$(curl -s -X POST "$URL/rest/v1/vault_payloads" \
  -H "apikey: $ANON_KEY" -H "Authorization: Bearer $TOK_A" \
  -H "Content-Type: application/json" -H "Prefer: return=representation" \
  -d "{\"device_id\":\"$DEV_A\",\"heir_id\":\"$HEIR_A\",\"heir_name\":\"Erbe\",\"heir_email\":\"a-heir@example.com\",\"policy\":\"komfort\",\"body\":\"geheim\"}")"
ROW_ID="$(echo "$INS_PAY" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)"
[ -n "$ROW_ID" ] && pass "vault_payloads von A angelegt (id=$ROW_ID)" \
  || fail "A konnte kein vault_payloads anlegen: $INS_PAY"

curl -s -X POST "$URL/rest/v1/vault_settings" \
  -H "apikey: $ANON_KEY" -H "Authorization: Bearer $TOK_A" \
  -H "Content-Type: application/json" -H "Prefer: return=minimal" \
  -d "{\"device_id\":\"$DEV_A\",\"owner_email\":\"a-owner@example.com\"}" >/dev/null

# --- Testfall 1: B liest -> muss leer sein ------------------------------
note "TC1 — Geraet B liest vault_payloads"
B_SEES="$(curl -s "$URL/rest/v1/vault_payloads?select=*" \
  -H "apikey: $ANON_KEY" -H "Authorization: Bearer $TOK_B")"
[ "$B_SEES" = "[]" ] && pass "B sieht 0 Zeilen" || fail "B sieht Fremddaten: $B_SEES"

# --- Testfall 2: reiner anon-Key ohne Session ---------------------------
note "TC2 — select=* nur mit anon-Key (keine Session)"
CODE="$(curl -s -o /tmp/tc2.body -w '%{http_code}' "$URL/rest/v1/vault_payloads?select=*" \
  -H "apikey: $ANON_KEY" -H "Authorization: Bearer $ANON_KEY")"
BODY="$(cat /tmp/tc2.body)"
if [ "$CODE" = "401" ] || [ "$CODE" = "403" ] || [ "$BODY" = "[]" ]; then
  pass "anon ohne Session: HTTP $CODE, Body=$BODY"
else
  fail "anon ohne Session liefert Daten: HTTP $CODE, Body=$BODY"
fi

# --- Testfall 3: B ueberschreibt A's heir_email -------------------------
note "TC3 — B patcht vault_payloads.heir_email von A"
PATCH3="$(curl -s -X PATCH "$URL/rest/v1/vault_payloads?id=eq.$ROW_ID" \
  -H "apikey: $ANON_KEY" -H "Authorization: Bearer $TOK_B" \
  -H "Content-Type: application/json" -H "Prefer: return=representation" \
  -d '{"heir_email":"attacker@evil.com"}')"
# Gegenprobe: A liest seine Zeile wieder.
A_AFTER="$(curl -s "$URL/rest/v1/vault_payloads?id=eq.$ROW_ID&select=heir_email" \
  -H "apikey: $ANON_KEY" -H "Authorization: Bearer $TOK_A")"
if [ "$PATCH3" = "[]" ] && echo "$A_AFTER" | grep -q 'a-heir@example.com'; then
  pass "B aendert nichts; A's heir_email unveraendert"
else
  fail "Fremd-Patch wirkte. patch=$PATCH3 a_after=$A_AFTER"
fi

# --- Testfall 4: B setzt A's confirmed_at -------------------------------
note "TC4 — B patcht vault_settings.confirmed_at von A"
PATCH4="$(curl -s -X PATCH "$URL/rest/v1/vault_settings?device_id=eq.$DEV_A" \
  -H "apikey: $ANON_KEY" -H "Authorization: Bearer $TOK_B" \
  -H "Content-Type: application/json" -H "Prefer: return=representation" \
  -d '{"confirmed_at":"2000-01-01T00:00:00Z"}')"
[ "$PATCH4" = "[]" ] && pass "B kann confirmed_at nicht setzen (0 Zeilen)" \
  || fail "Fremd-Patch auf confirmed_at wirkte: $PATCH4"

note "Ergebnis"
[ "$FAILED" = "0" ] && { echo "  Alle vier Testfaelle GRUEN."; exit 0; } \
  || { echo "  Mindestens ein Testfall ROT."; exit 1; }
