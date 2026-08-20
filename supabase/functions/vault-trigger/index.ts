// vault-trigger — vom pg_cron-Job taeglich gerufen. Scant
// vault_settings, sendet Vorwarnungen bei 80 % des Intervalls und
// versendet bei 100 % + 14 Tagen die fertig hinterlegten Payloads an
// die Erben.
//
// E-Mail-Versand: ueber Resend. Setze RESEND_API_KEY und VAULT_FROM_EMAIL
// als Secrets der Edge Function. Wenn der Key fehlt, schreibt die Funktion
// die geplanten Mails ins Log statt sie zu versenden.
//
// Sicherheitsfilter: die Funktion darf nur mit dem Service-Role-Key
// oder ohne Auth (vom pg_cron via pg_net) aufgerufen werden — externe
// Auslöser werden 401 abgewiesen, sobald `Authorization` nicht der
// erwartete Token ist.

import { corsHeaders, jsonHeaders } from '../_shared/cors.ts';
import { randomToken, sha256Hex } from '../_shared/token.ts';

interface VaultSetting {
  device_id: string;
  owner_name: string | null;
  owner_email: string;
  interval_days: number;
  enabled: boolean;
  confirmed_at: string;
  warning_sent_at: string | null;
  warning_count: number | null;
  heir_notified_at: string | null;
  notify_attempts: number | null;
  owner_alerted_at: string | null;
}

interface Payload {
  id: string;
  heir_id: string;
  heir_name: string;
  heir_email: string;
  policy: string;
  body: string;
  pdf_b64: string | null;
  sent_at: string | null;
}

// Nach so vielen fehlgeschlagenen Zustell-Durchlaeufen wird der Owner einmalig
// per E-Mail informiert (der taegliche Cron liefert die Wiederhol-Kadenz).
const MAX_NOTIFY_ATTEMPTS = 5;

const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
const resendKey  = Deno.env.get('RESEND_API_KEY') ?? '';
const fromEmail  = Deno.env.get('VAULT_FROM_EMAIL') ?? 'no-reply@pacto.app';

async function fetchSettings(): Promise<VaultSetting[]> {
  const res = await fetch(
    `${supabaseUrl}/rest/v1/vault_settings?enabled=eq.true&select=*`,
    {
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
      },
    },
  );
  if (!res.ok) throw new Error(`Could not fetch vault_settings: ${await res.text()}`);
  return (await res.json()) as VaultSetting[];
}

async function fetchPayloads(deviceId: string): Promise<Payload[]> {
  const res = await fetch(
    `${supabaseUrl}/rest/v1/vault_payloads?device_id=eq.${deviceId}&select=id,heir_id,heir_name,heir_email,policy,body,pdf_b64,sent_at`,
    {
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
      },
    },
  );
  if (!res.ok) throw new Error(`Could not fetch vault_payloads: ${await res.text()}`);
  return (await res.json()) as Payload[];
}

// Markiert einen Erben-Brief als erfolgreich zugestellt.
async function markPayloadSent(id: string) {
  await fetch(`${supabaseUrl}/rest/v1/vault_payloads?id=eq.${id}`, {
    method: 'PATCH',
    headers: {
      apikey: serviceKey,
      Authorization: `Bearer ${serviceKey}`,
      'Content-Type': 'application/json',
      Prefer: 'return=minimal',
    },
    body: JSON.stringify({ sent_at: new Date().toISOString() }),
  });
}

async function mark(deviceId: string, fields: Record<string, unknown>) {
  await fetch(
    `${supabaseUrl}/rest/v1/vault_settings?device_id=eq.${deviceId}`,
    {
      method: 'PATCH',
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
        'Content-Type': 'application/json',
        Prefer: 'return=minimal',
      },
      body: JSON.stringify({ ...fields, updated_at: new Date().toISOString() }),
    },
  );
}

async function log(deviceId: string, event: string, message: string) {
  await fetch(`${supabaseUrl}/rest/v1/vault_log`, {
    method: 'POST',
    headers: {
      apikey: serviceKey,
      Authorization: `Bearer ${serviceKey}`,
      'Content-Type': 'application/json',
      Prefer: 'return=minimal',
    },
    body: JSON.stringify({ device_id: deviceId, event, message }),
  });
}

async function sendEmail(opts: {
  to: string;
  subject: string;
  text: string;
  attachments?: { filename: string; content: string }[];
}): Promise<{ sent: boolean; error?: string }> {
  if (!resendKey) {
    return { sent: false, error: 'RESEND_API_KEY missing — email not sent' };
  }
  const res = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${resendKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from: fromEmail,
      to: [opts.to],
      subject: opts.subject,
      text: opts.text,
      attachments: opts.attachments,
    }),
  });
  if (!res.ok) {
    return { sent: false, error: await res.text() };
  }
  return { sent: true };
}

// Erzeugt ein Reset-Token, legt seinen Hash + Ablauf ab und gibt das Klartext-
// Token zurueck (fuer den Link in der Mail). Gueltig bis kurz nach dem
// Ausloesezeitpunkt.
async function issueResetToken(
  deviceId: string,
  confirmedAt: string,
  intervalDays: number,
): Promise<string> {
  const raw = randomToken(32);
  const hash = await sha256Hex(raw);
  const expires = new Date(
    new Date(confirmedAt).getTime() + (intervalDays + 16) * 86400000,
  ).toISOString();
  await fetch(`${supabaseUrl}/rest/v1/vault_reset_tokens`, {
    method: 'POST',
    headers: {
      apikey: serviceKey,
      Authorization: `Bearer ${serviceKey}`,
      'Content-Type': 'application/json',
      Prefer: 'return=minimal,resolution=merge-duplicates',
    },
    body: JSON.stringify({
      token_hash: hash,
      device_id: deviceId,
      expires_at: expires,
    }),
  });
  return raw;
}

// Vorwarnung mit Widerrufs-Link in einfacher Sprache.
async function sendWarning(
  s: VaultSetting,
  elapsed: number,
  interval: number,
): Promise<{ sent: boolean; error?: string }> {
  const raw = await issueResetToken(s.device_id, s.confirmed_at, interval);
  const link = `${supabaseUrl}/functions/v1/vault-postpone?token=${raw}`;
  const remaining = Math.max(0, Math.round(interval + 14 - elapsed));
  return sendEmail({
    to: s.owner_email,
    subject: 'Pacto — bist du noch da?',
    text:
      `Hallo${s.owner_name ? ' ' + s.owner_name : ''},\n\n` +
      `wir haben dich seit ${Math.round(elapsed)} Tagen nicht in Pacto ` +
      `gesehen.\n\n` +
      `Wenn du nichts tust, benachrichtigt Pacto in etwa ${remaining} Tagen ` +
      `die von dir hinterlegten Erben und schickt ihnen deine ` +
      `Vertragsuebersicht.\n\n` +
      `Wenn alles in Ordnung ist, klicke einfach auf diesen Link — das reicht ` +
      `als Lebenszeichen, und es passiert nichts weiter:\n\n${link}\n\n` +
      `Du musst die App dafuer nicht oeffnen.\n\nDein Pacto`,
  });
}

function daysSince(iso: string): number {
  const then = new Date(iso).getTime();
  return (Date.now() - then) / (1000 * 60 * 60 * 24);
}

// `force` = Testmodus: sendet sofort an die Erben, unabhaengig vom Timing, und
// setzt `heir_notified_at` NICHT — so ist der Test beliebig wiederholbar.
async function processOne(s: VaultSetting, force = false): Promise<string> {
  const elapsed = daysSince(s.confirmed_at);
  const interval = s.interval_days;
  const warn1Point = interval * 0.8; // erste Vorwarnung
  const warn2Point = interval; // zweite Vorwarnung (100 %)
  const triggerPoint = interval + 14;
  const wcount = s.warning_count ?? 0;

  // 1. Erben wurden schon benachrichtigt — nichts mehr tun (im Test ignoriert).
  if (!force && s.heir_notified_at) return 'already_notified';

  // 2. Trigger erreicht — aber erst nach MINDESTENS ZWEI Vorwarnungen ausloesen
  //    (Test erzwungen umgeht das). So kann niemand ohne Vorwarnung "feuern".
  if (force || (elapsed >= triggerPoint && wcount >= 2)) {
    const payloads = await fetchPayloads(s.device_id);
    if (payloads.length === 0) {
      await log(s.device_id, 'heir_sent', 'No payloads stored, skipped');
      return 'no_payloads';
    }
    // Nur noch nicht zugestellte Briefe senden (im Test: alle). So werden bei
    // einem Wiederholungslauf bereits erreichte Erben nicht doppelt angemailt.
    const pending = force ? payloads : payloads.filter((p) => !p.sent_at);
    let sent = 0;
    let failed = 0;
    for (const p of pending) {
      const result = await sendEmail({
        to: p.heir_email,
        subject: `${force ? '[TEST] ' : ''}Pacto-Uebersicht von ${s.owner_name ?? 'einem Pacto-Nutzer'}`,
        text: p.body,
        attachments: p.pdf_b64
          ? [{ filename: 'pacto.pdf', content: p.pdf_b64 }]
          : undefined,
      });
      if (result.sent) {
        sent++;
        if (!force) await markPayloadSent(p.id); // pro Erbe erst bei Erfolg
      } else {
        failed++;
      }
    }

    // Im Testmodus keinen Zustand veraendern (beliebig wiederholbar).
    if (force) {
      await log(s.device_id, 'heir_test', `TEST sent=${sent} failed=${failed}`);
      return `test_heirs_notified (${sent}/${pending.length})`;
    }

    const attempts = (s.notify_attempts ?? 0) + 1;
    if (failed === 0) {
      // Alle offenen Briefe zugestellt -> erledigt. Erst JETZT heir_notified_at.
      await mark(s.device_id, {
        heir_notified_at: new Date().toISOString(),
        notify_attempts: attempts,
      });
      await log(s.device_id, 'heir_sent', `all delivered (sent=${sent})`);
      return `heirs_notified (${sent}/${pending.length})`;
    }

    // Teil-/Fehlschlag: heir_notified_at bleibt null -> naechster Cron-Tag
    // versucht die offenen erneut. Nach mehreren Versuchen den Owner einmalig
    // informieren.
    const patch: Record<string, unknown> = { notify_attempts: attempts };
    let alerted = false;
    if (attempts >= MAX_NOTIFY_ATTEMPTS && !s.owner_alerted_at) {
      const r = await sendEmail({
        to: s.owner_email,
        subject: 'Pacto — Zustellung an deine Erben schlaegt fehl',
        text:
          `Hallo${s.owner_name ? ' ' + s.owner_name : ''},\n\n` +
          `Pacto versucht seit einigen Tagen, deine hinterlegte Uebersicht an ` +
          `deine Erben zu senden, aber die Zustellung schlaegt fehl. Bitte ` +
          `pruefe die hinterlegten E-Mail-Adressen der Erben in der App.\n\n` +
          `Wir versuchen es weiter.\n\nDein Pacto`,
      });
      if (r.sent) {
        patch.owner_alerted_at = new Date().toISOString();
        alerted = true;
      }
    }
    await mark(s.device_id, patch);
    await log(
      s.device_id,
      'heir_sent',
      `partial: sent=${sent} failed=${failed} attempt=${attempts}` +
        (alerted ? ' owner_alerted' : ''),
    );
    return `heirs_partial (${sent} ok, ${failed} offen, Versuch ${attempts})`;
  }

  // 3. Erste Vorwarnung bei 80 %.
  if (elapsed >= warn1Point && wcount < 1) {
    const result = await sendWarning(s, elapsed, interval);
    await mark(s.device_id, {
      warning_count: 1,
      warning_sent_at: new Date().toISOString(),
    });
    // Kein roher Fehlertext ins Log — koennte die Empfaengeradresse spiegeln.
    await log(s.device_id, 'warning', result.sent ? 'sent (1/2)' : 'failed (1/2)');
    return 'warning1_sent';
  }

  // 4. Zweite Vorwarnung bei 100 % — laeuft am naechsten Cron-Tag nach der
  //    ersten, sodass immer zwei Warnungen vor der Ausloesung stehen.
  if (elapsed >= warn2Point && wcount < 2) {
    const result = await sendWarning(s, elapsed, interval);
    await mark(s.device_id, {
      warning_count: 2,
      warning_sent_at: new Date().toISOString(),
    });
    await log(s.device_id, 'warning', result.sent ? 'sent (2/2)' : 'failed (2/2)');
    return 'warning2_sent';
  }

  return 'ok';
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }
  const auth = req.headers.get('Authorization') ?? '';
  if (auth !== `Bearer ${serviceKey}`) {
    return new Response('Unauthorized', { status: 401, headers: corsHeaders });
  }
  try {
    // Optionaler Test-Body: { force: true, deviceId?: "..." } sendet sofort,
    // ohne auf das Inaktivitaets-Intervall zu warten. Ohne Body laeuft der
    // normale Cron-Durchlauf.
    let force = false;
    let onlyDevice: string | null = null;
    try {
      const body = await req.json();
      force = body?.force === true;
      onlyDevice = typeof body?.deviceId === 'string' ? body.deviceId : null;
    } catch (_) {
      // kein/ungueltiger Body → normaler Lauf
    }

    const all = await fetchSettings();
    const settings =
        onlyDevice == null ? all : all.filter((s) => s.device_id === onlyDevice);
    const summary: Record<string, string> = {};
    for (const s of settings) {
      try {
        summary[s.device_id] = await processOne(s, force);
      } catch (e) {
        const msg = e instanceof Error ? e.message : String(e);
        summary[s.device_id] = `error: ${msg}`;
        await log(s.device_id, 'warning', `processing error: ${msg}`);
      }
    }
    return new Response(JSON.stringify({ ok: true, processed: settings.length, summary }), {
      headers: jsonHeaders,
    });
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    return new Response(JSON.stringify({ error: msg }), {
      status: 500, headers: jsonHeaders,
    });
  }
});
