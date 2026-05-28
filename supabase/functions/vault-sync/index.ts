// vault-sync — App lieferst fertig gerenderte Erben-Briefe (eine Zeile pro
// Erbe). Der Server haelt sie auf Vorrat, bis der Trigger feuert.
//
// Body:
// {
//   deviceId: string,
//   payloads: [
//     { heirId, heirName, heirEmail, policy, body, pdfB64? }
//   ]
// }
//
// Wir ueberschreiben jeweils die ganze Liste fuer device_id, damit
// geloeschte Erben bzw. geloeschte Vertraege nicht haengen bleiben.

import { corsHeaders, jsonHeaders } from '../_shared/cors.ts';

interface IncomingPayload {
  heirId: string;
  heirName: string;
  heirEmail: string;
  policy: 'none' | 'komfort' | 'maximum';
  body: string;
  pdfB64?: string;
}

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
    const { deviceId, payloads } = await req.json();
    if (!deviceId || !Array.isArray(payloads)) {
      return new Response(
        JSON.stringify({ error: 'deviceId or payloads missing' }),
        { status: 400, headers: jsonHeaders },
      );
    }

    // 1. Alte Payloads fuer das Geraet wegputzen.
    const delRes = await fetch(
      `${supabaseUrl}/rest/v1/vault_payloads?device_id=eq.${deviceId}`,
      {
        method: 'DELETE',
        headers: {
          apikey: serviceKey,
          Authorization: `Bearer ${serviceKey}`,
        },
      },
    );
    if (!delRes.ok) {
      const text = await delRes.text();
      return new Response(JSON.stringify({ error: `delete failed: ${text}` }), {
        status: 500, headers: jsonHeaders,
      });
    }

    if (payloads.length === 0) {
      return new Response(JSON.stringify({ ok: true, count: 0 }), {
        headers: jsonHeaders,
      });
    }

    // 2. Neu einspielen.
    const rows = (payloads as IncomingPayload[]).map((p) => ({
      device_id: deviceId,
      heir_id: p.heirId,
      heir_name: p.heirName,
      heir_email: p.heirEmail,
      policy: p.policy,
      body: p.body,
      pdf_b64: p.pdfB64 ?? null,
      updated_at: new Date().toISOString(),
    }));
    const insRes = await fetch(`${supabaseUrl}/rest/v1/vault_payloads`, {
      method: 'POST',
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
        'Content-Type': 'application/json',
        Prefer: 'return=minimal',
      },
      body: JSON.stringify(rows),
    });
    if (!insRes.ok) {
      const text = await insRes.text();
      return new Response(JSON.stringify({ error: `insert failed: ${text}` }), {
        status: 500, headers: jsonHeaders,
      });
    }
    return new Response(JSON.stringify({ ok: true, count: rows.length }), {
      headers: jsonHeaders,
    });
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    return new Response(JSON.stringify({ error: msg }), {
      status: 500, headers: jsonHeaders,
    });
  }
});
