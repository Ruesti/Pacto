// vault-postpone — oeffentlicher Widerrufs-Link aus den Vorwarnungs-Mails.
//
// Ein Klick auf den Link (GET mit ?token=...) schiebt die Ausloesung auf:
// confirmed_at = now(), Vorwarnungen werden zurueckgesetzt. Kein App-Start
// noetig — funktioniert auch nach einer Deinstallation.
//
// Diese Funktion darf AUSSCHLIESSLICH aufschieben. Sie liest, aendert oder
// loescht keine Nutzer-/Vertrags-/Erbendaten und gibt keine solchen Daten aus.
// Sie ist idempotent bis zum Ablauf des Tokens (robust gegen Mail-Prefetch).
//
// Auth: kein JWT (config.toml: verify_jwt = false) — das hochentropige Token
// IST der Berechtigungsnachweis. Serverseitig liegt nur sein Hash.

import { sha256Hex } from '../_shared/token.ts';

const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

function page(status: number, title: string, message: string): Response {
  const body = `<!doctype html>
<html lang="de"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${title} — Pacto</title>
<style>
  body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;
    background:#0A0A0F;color:#fff;margin:0;display:flex;min-height:100vh;
    align-items:center;justify-content:center;padding:24px}
  .card{background:#15151E;border:1px solid rgba(255,255,255,.1);border-radius:16px;
    padding:28px;max-width:420px}
  h1{font-size:20px;margin:0 0 12px}
  p{font-size:15px;line-height:1.5;color:rgba(255,255,255,.8);margin:0}
</style></head>
<body><div class="card"><h1>${title}</h1><p>${message}</p></div></body></html>`;
  return new Response(body, {
    status,
    headers: { 'Content-Type': 'text/html; charset=utf-8' },
  });
}

Deno.serve(async (req: Request) => {
  const url = new URL(req.url);
  const raw = url.searchParams.get('token') ?? '';
  if (!raw) {
    return page(400, 'Ungueltiger Link', 'Diesem Link fehlt das Token.');
  }

  const hash = await sha256Hex(raw);

  // Token nachschlagen (nur ueber den Hash).
  const tokRes = await fetch(
    `${supabaseUrl}/rest/v1/vault_reset_tokens?token_hash=eq.${hash}&select=device_id,expires_at`,
    { headers: { apikey: serviceKey, Authorization: `Bearer ${serviceKey}` } },
  );
  const rows = tokRes.ok ? await tokRes.json() : [];
  const tok = Array.isArray(rows) && rows.length > 0 ? rows[0] : null;
  if (!tok || new Date(tok.expires_at).getTime() < Date.now()) {
    return page(
      410,
      'Link nicht mehr gueltig',
      'Dieser Link ist abgelaufen oder wurde bereits durch einen neueren ersetzt. '
      + 'Wenn du sichergehen willst, oeffne kurz die Pacto-App auf deinem Geraet.',
    );
  }

  // Aufschieben: confirmed_at = now(), Vorwarnungen zuruecksetzen. Sonst nichts.
  const now = new Date().toISOString();
  const patch = await fetch(
    `${supabaseUrl}/rest/v1/vault_settings?device_id=eq.${tok.device_id}`,
    {
      method: 'PATCH',
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
        'Content-Type': 'application/json',
        Prefer: 'return=minimal',
      },
      body: JSON.stringify({
        confirmed_at: now,
        warning_sent_at: null,
        warning_count: 0,
        updated_at: now,
      }),
    },
  );
  if (!patch.ok) {
    return page(
      500,
      'Etwas ging schief',
      'Wir konnten dein Lebenszeichen gerade nicht speichern. Bitte versuche es '
      + 'in ein paar Minuten noch einmal oder oeffne die Pacto-App.',
    );
  }

  return page(
    200,
    'Alles bleibt, wie es ist',
    'Danke — wir haben dein Lebenszeichen erhalten. Es wird niemand '
    + 'benachrichtigt, und du musst nichts weiter tun.',
  );
});
