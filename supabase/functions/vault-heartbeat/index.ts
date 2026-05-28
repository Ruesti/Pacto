// vault-heartbeat — App POSTet beim Start / Resume und nach jedem
// "ich-bin-noch-da" Magic-Link-Klick. Setzt confirmed_at = now() und loescht
// warning_sent_at, damit die naechste Vorwarnung wieder feuern kann.
//
// Body: { deviceId: string, ownerName?: string, ownerEmail?: string,
//         intervalDays?: number, enabled?: boolean }
//
// Wenn die Zeile noch nicht existiert, wird sie angelegt — daher koennen
// alle Felder beim ersten Heartbeat mitkommen.

import { corsHeaders, jsonHeaders } from '../_shared/cors.ts';

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }
  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', { status: 405, headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const body = await req.json();
    const deviceId = body.deviceId as string | undefined;
    if (!deviceId) {
      return new Response(JSON.stringify({ error: 'deviceId missing' }), {
        status: 400, headers: jsonHeaders,
      });
    }

    const row: Record<string, unknown> = {
      device_id: deviceId,
      confirmed_at: new Date().toISOString(),
      warning_sent_at: null,
      heir_notified_at: null,
      updated_at: new Date().toISOString(),
    };
    if (typeof body.ownerName === 'string') row.owner_name = body.ownerName;
    if (typeof body.ownerEmail === 'string') row.owner_email = body.ownerEmail;
    if (typeof body.intervalDays === 'number') row.interval_days = body.intervalDays;
    if (typeof body.enabled === 'boolean') row.enabled = body.enabled;

    const res = await fetch(
      `${supabaseUrl}/rest/v1/vault_settings?on_conflict=device_id`,
      {
        method: 'POST',
        headers: {
          apikey: serviceKey,
          Authorization: `Bearer ${serviceKey}`,
          'Content-Type': 'application/json',
          Prefer: 'resolution=merge-duplicates,return=minimal',
        },
        body: JSON.stringify(row),
      },
    );
    if (!res.ok) {
      const text = await res.text();
      return new Response(JSON.stringify({ error: text }), {
        status: 500, headers: jsonHeaders,
      });
    }
    return new Response(JSON.stringify({ ok: true }), { headers: jsonHeaders });
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    return new Response(JSON.stringify({ error: msg }), {
      status: 500, headers: jsonHeaders,
    });
  }
});
