// Gemeinsame Auth-Hilfe fuer die client-gerufenen Edge Functions.
//
// Loest den Supabase-User aus dem Bearer-Token des Requests auf. Ein blosser
// anon-Key (Rolle `anon`, kein `sub`) oder ein fehlendes/ungueltiges Token
// ergibt `null` — die aufrufende Funktion antwortet dann mit 401.
//
// WICHTIG: Die Funktionen schreiben anschliessend mit GENAU diesem Token gegen
// PostgREST. Dadurch greift Row Level Security ((select auth.uid()) = user_id);
// die Funktionen brauchen keinen Service-Role-Key mehr und koennen fremde
// Zeilen nicht anfassen.

export interface AuthedUser {
  id: string;
  token: string;
}

export async function getUser(req: Request): Promise<AuthedUser | null> {
  const authHeader = req.headers.get('Authorization') ?? '';
  const token = authHeader.replace(/^Bearer\s+/i, '').trim();
  if (!token) return null;

  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';

  const res = await fetch(`${supabaseUrl}/auth/v1/user`, {
    headers: {
      apikey: anonKey,
      Authorization: `Bearer ${token}`,
    },
  });
  if (!res.ok) return null;

  let user: { id?: string } | null = null;
  try {
    user = await res.json();
  } catch (_) {
    return null;
  }
  if (!user || typeof user.id !== 'string' || user.id.length === 0) {
    return null;
  }
  return { id: user.id, token };
}
