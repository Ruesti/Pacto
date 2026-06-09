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

interface VaultSetting {
  device_id: string;
  owner_name: string | null;
  owner_email: string;
  interval_days: number;
  enabled: boolean;
  confirmed_at: string;
  warning_sent_at: string | null;
  heir_notified_at: string | null;
}

interface Payload {
  heir_id: string;
  heir_name: string;
  heir_email: string;
  policy: string;
  body: string;
  pdf_b64: string | null;
}

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
    `${supabaseUrl}/rest/v1/vault_payloads?device_id=eq.${deviceId}&select=heir_id,heir_name,heir_email,policy,body,pdf_b64`,
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

function daysSince(iso: string): number {
  const then = new Date(iso).getTime();
  return (Date.now() - then) / (1000 * 60 * 60 * 24);
}

// `force` = Testmodus: sendet sofort an die Erben, unabhaengig vom Timing, und
// setzt `heir_notified_at` NICHT — so ist der Test beliebig wiederholbar.
async function processOne(s: VaultSetting, force = false): Promise<string> {
  const elapsed = daysSince(s.confirmed_at);
  const interval = s.interval_days;
  const warningPoint = interval * 0.8;
  const triggerPoint = interval + 14;

  // 1. Erben wurden schon benachrichtigt — nichts mehr tun (im Test ignoriert).
  if (!force && s.heir_notified_at) return 'already_notified';

  // 2. Trigger erreicht (oder Test erzwungen) — Erben informieren.
  if (force || elapsed >= triggerPoint) {
    const payloads = await fetchPayloads(s.device_id);
    if (payloads.length === 0) {
      await log(s.device_id, 'heir_sent', 'No payloads stored, skipped');
      return 'no_payloads';
    }
    let sent = 0;
    const errors: string[] = [];
    for (const p of payloads) {
      const result = await sendEmail({
        to: p.heir_email,
        subject: `${force ? '[TEST] ' : ''}Pacto-Uebersicht von ${s.owner_name ?? 'einem Pacto-Nutzer'}`,
        text: p.body,
        attachments: p.pdf_b64
          ? [{ filename: 'pacto.pdf', content: p.pdf_b64 }]
          : undefined,
      });
      if (result.sent) sent++;
      else errors.push(`${p.heir_email}: ${result.error}`);
    }
    // Im Testmodus den Zustand nicht verbrennen.
    if (!force) {
      await mark(s.device_id, { heir_notified_at: new Date().toISOString() });
    }
    await log(
      s.device_id,
      force ? 'heir_test' : 'heir_sent',
      `${force ? 'TEST ' : ''}sent=${sent} errors=${errors.join(' | ')}`,
    );
    return `${force ? 'test_' : ''}heirs_notified (${sent}/${payloads.length})`;
  }

  // 3. Vorwarnung bei 80 % — nur einmal pro Intervall.
  if (elapsed >= warningPoint && !s.warning_sent_at) {
    const result = await sendEmail({
      to: s.owner_email,
      subject: 'Pacto — bist du noch da?',
      text:
        `Hallo${s.owner_name ? ' ' + s.owner_name : ''},\n\n` +
        `wir haben dich seit ${Math.round(elapsed)} Tagen nicht in Pacto ` +
        `gesehen. In ${Math.max(0, Math.round(interval - elapsed))} Tagen ` +
        `wuerden wir deine hinterlegten Erben benachrichtigen.\n\n` +
        `Wenn alles in Ordnung ist, oeffne kurz die App — das reicht als ` +
        `Lebenszeichen.\n\nDein Pacto`,
    });
    await mark(s.device_id, { warning_sent_at: new Date().toISOString() });
    await log(
      s.device_id,
      'warning',
      result.sent ? 'sent' : `failed: ${result.error}`,
    );
    return 'warning_sent';
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
