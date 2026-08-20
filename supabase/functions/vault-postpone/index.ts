// vault-postpone — oeffentlicher Widerrufs-Link aus den Vorwarnungs-Mails.
//
// Zweistufig, damit ein Mail-Scanner den Link nicht versehentlich ausloest:
//   * GET  ?token=...  -> zeigt nur eine Bestaetigungsseite (KEINE Aenderung).
//   * POST ?token=...  -> schiebt die Ausloesung auf: confirmed_at = now(),
//                          Vorwarnungen zurueck. Mehr nicht.
// Automatische Link-Vorschauen (GET) veraendern also nichts; erst der bewusste
// Klick auf den Button (POST) zaehlt.
//
// Diese Funktion darf AUSSCHLIESSLICH aufschieben. Sie liest, aendert oder
// loescht keine Nutzer-/Vertrags-/Erbendaten und gibt keine solchen Daten aus.
// Idempotent bis zum Ablauf des Tokens.
//
// Auth: kein JWT (config.toml: verify_jwt = false) — das hochentropige Token IST
// der Berechtigungsnachweis. Serverseitig liegt nur sein Hash. Bewusst
// akzeptiert (Brief Phase 3): Wer Zugriff auf das Postfach hat, kann aufschieben
// — owner_email ist ohnehin der Vertrauensanker des Mechanismus.

import { sha256Hex } from '../_shared/token.ts';

const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

function shell(title: string, inner: string, status = 200): Response {
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
  p{font-size:15px;line-height:1.5;color:rgba(255,255,255,.8);margin:0 0 20px}
  button{background:#7C5CE7;color:#fff;border:0;border-radius:12px;padding:14px 20px;
    font-size:16px;font-weight:600;width:100%;cursor:pointer}
</style></head>
<body><div class="card">${inner}</div></body></html>`;
  return new Response(body, {
    status,
    headers: { 'Content-Type': 'text/html; charset=utf-8' },
  });
}

function message(title: string, text: string, status = 200): Response {
  return shell(title, `<h1>${title}</h1><p>${text}</p>`, status);
}

async function lookupToken(
  raw: string,
): Promise<{ device_id: string; expires_at: string } | null> {
  const hash = await sha256Hex(raw);
  const res = await fetch(
    `${supabaseUrl}/rest/v1/vault_reset_tokens?token_hash=eq.${hash}&select=device_id,expires_at`,
    { headers: { apikey: serviceKey, Authorization: `Bearer ${serviceKey}` } },
  );
  const rows = res.ok ? await res.json() : [];
  const tok = Array.isArray(rows) && rows.length > 0 ? rows[0] : null;
  if (!tok || new Date(tok.expires_at).getTime() < Date.now()) return null;
  return tok;
}

Deno.serve(async (req: Request) => {
  const url = new URL(req.url);
  const raw = url.searchParams.get('token') ?? '';
  if (!raw) {
    return message('Ungueltiger Link', 'Diesem Link fehlt das Token.', 400);
  }

  const tok = await lookupToken(raw);
  const expiredMsg =
    'Dieser Link ist abgelaufen oder wurde durch einen neueren ersetzt. '
    + 'Wenn du sichergehen willst, oeffne kurz die Pacto-App auf deinem Geraet.';

  // GET: nur bestaetigen lassen, nichts aendern (schuetzt vor Link-Vorschau).
  if (req.method === 'GET') {
    if (!tok) return message('Link nicht mehr gueltig', expiredMsg, 410);
    const action = `?token=${encodeURIComponent(raw)}`;
    return shell(
      'Bist du noch da?',
      `<h1>Bist du noch da?</h1>
       <p>Klicke auf den Button, um Pacto zu bestaetigen, dass alles in Ordnung
       ist. Es wird dann niemand benachrichtigt.</p>
       <form method="POST" action="${action}">
         <button type="submit">Ja, ich bin noch da</button>
       </form>`,
    );
  }

  if (req.method !== 'POST') {
    return message('Nicht erlaubt', 'Methode nicht unterstuetzt.', 405);
  }

  // POST: der bewusste Klick — jetzt aufschieben.
  if (!tok) return message('Link nicht mehr gueltig', expiredMsg, 410);

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
        notify_attempts: 0,
        owner_alerted_at: null,
        updated_at: now,
      }),
    },
  );
  if (!patch.ok) {
    return message(
      'Etwas ging schief',
      'Wir konnten dein Lebenszeichen gerade nicht speichern. Bitte versuche es '
      + 'in ein paar Minuten noch einmal oder oeffne die Pacto-App.',
      500,
    );
  }

  return message(
    'Alles bleibt, wie es ist',
    'Danke — wir haben dein Lebenszeichen erhalten. Es wird niemand '
    + 'benachrichtigt, und du musst nichts weiter tun.',
  );
});
