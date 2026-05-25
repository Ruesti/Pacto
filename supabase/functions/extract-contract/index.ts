import Anthropic from 'npm:@anthropic-ai/sdk@0.27.0';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const SYSTEM_PROMPT = `Du bist ein Datenextraktions-Assistent für Verträge und Abonnements.
Antworte AUSSCHLIESSLICH mit einem JSON-Objekt. Kein Kommentar, kein Markdown.
Felder:
{
  "name": "Produktname / Abo-Name",
  "provider": "Unternehmensname",
  "category": "streaming|versicherung|handy|internet|software|fitness|zeitung|sonstiges",
  "monthlyCost": 9.99,
  "billingCycle": "monthly|quarterly|yearly|weekly",
  "contactPhone": "+49...",
  "contactEmail": "kuendigung@...",
  "contactUrl": "https://...",
  "noticePeriod": "Freitext z.B. '3 Monate zum Quartalsende'",
  "cancellationMethod": "brief|online|telefon|email|automatisch",
  "cancellationInstructions": "Schritt-für-Schritt Anleitung auf Deutsch",
  "nextRenewal": "YYYY-MM-DD oder null",
  "notes": "Besonderheiten, Sonderkündigungsrecht etc."
}
Fehlende Felder als null. monthlyCost immer als Monatsbetrag (Jahresbetrag ÷ 12).`;

// Aktueller Scan-Zaehler des Users fuer den angegebenen Monat ('YYYY-MM').
async function getScanCount(
  supabaseUrl: string,
  serviceKey: string,
  userId: string,
  month: string,
): Promise<number> {
  const res = await fetch(
    `${supabaseUrl}/rest/v1/scan_counts?user_id=eq.${userId}&month=eq.${month}&select=count`,
    {
      headers: {
        'apikey': serviceKey,
        'Authorization': `Bearer ${serviceKey}`,
      },
    }
  );
  if (!res.ok) return 0;
  const data = await res.json();
  return data[0]?.count ?? 0;
}

// Schreibt den neuen Zaehlerstand. Upsert ueber den Primaerschluessel
// (user_id, month) — vorhandene Zeilen werden aktualisiert statt dupliziert.
async function setScanCount(
  supabaseUrl: string,
  serviceKey: string,
  userId: string,
  month: string,
  count: number,
): Promise<void> {
  await fetch(`${supabaseUrl}/rest/v1/scan_counts?on_conflict=user_id,month`, {
    method: 'POST',
    headers: {
      'apikey': serviceKey,
      'Authorization': `Bearer ${serviceKey}`,
      'Content-Type': 'application/json',
      'Prefer': 'resolution=merge-duplicates,return=minimal',
    },
    body: JSON.stringify({ user_id: userId, month, count }),
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response('Unauthorized', { status: 401, headers: corsHeaders });
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const anthropicKey = Deno.env.get('ANTHROPIC_API_KEY') ?? '';

    // Verify JWT to get user ID
    const jwtToken = authHeader.replace('Bearer ', '');
    const userRes = await fetch(`${supabaseUrl}/auth/v1/user`, {
      headers: {
        'apikey': serviceKey,
        'Authorization': `Bearer ${jwtToken}`,
      },
    });

    if (!userRes.ok) {
      return new Response('Unauthorized', { status: 401, headers: corsHeaders });
    }

    const user = await userRes.json();
    const userId = user.id;

    // Rate limit: max 100 scans per user per month
    const month = new Date().toISOString().substring(0, 7);
    const scanCount = await getScanCount(supabaseUrl, serviceKey, userId, month);
    if (scanCount >= 100) {
      return new Response(
        JSON.stringify({ error: 'Monatliches Scan-Limit (100) erreicht' }),
        { status: 429, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const { imageBase64, mediaType, url } = await req.json();

    const client = new Anthropic({ apiKey: anthropicKey });

    let message;

    if (url) {
      const pageRes = await fetch(url, {
        headers: {
          'User-Agent': 'Mozilla/5.0 (compatible; Pacto-Bot/1.0)',
          'Accept': 'text/html,application/xhtml+xml',
          'Accept-Language': 'de,en;q=0.9',
        },
      });
      let pageText = await pageRes.text();
      if (pageText.length > 50_000) pageText = pageText.substring(0, 50_000);

      message = await client.messages.create({
        model: 'claude-haiku-4-5-20251001',
        max_tokens: 1024,
        system: SYSTEM_PROMPT,
        messages: [
          {
            role: 'user',
            content: `URL: ${url}\n\nSeiteninhalt (HTML):\n${pageText}\n\nExtrahiere die Vertragsdaten aus diesem Webseiteninhalt.`,
          },
        ],
      });
    } else if (imageBase64) {
      message = await client.messages.create({
        model: 'claude-haiku-4-5-20251001',
        max_tokens: 1024,
        system: SYSTEM_PROMPT,
        messages: [
          {
            role: 'user',
            content: [
              {
                type: 'image',
                source: {
                  type: 'base64',
                  media_type: mediaType as 'image/jpeg' | 'image/png' | 'image/gif' | 'image/webp',
                  data: imageBase64,
                },
              },
              {
                type: 'text',
                text: 'Extrahiere die Vertragsdaten aus diesem Dokument.',
              },
            ],
          },
        ],
      });
    } else {
      return new Response(
        JSON.stringify({ error: 'Weder imageBase64 noch url angegeben' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const responseText = message.content[0].type === 'text' ? message.content[0].text : '{}';

    // Parse JSON response
    let extractedData;
    try {
      extractedData = JSON.parse(responseText);
    } catch {
      // Try to extract JSON from response if wrapped in markdown
      const jsonMatch = responseText.match(/\{[\s\S]*\}/);
      extractedData = jsonMatch ? JSON.parse(jsonMatch[0]) : {};
    }

    await setScanCount(supabaseUrl, serviceKey, userId, month, scanCount + 1);

    return new Response(
      JSON.stringify(extractedData),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (error) {
    console.error('Extraction error:', error);
    return new Response(
      JSON.stringify({ error: 'Extraktionsfehler' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});
