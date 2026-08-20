// Hilfen fuer das Reset-Token (Phase 3).
//
// Das Token traegt >=256 Bit Entropie; serverseitig wird NUR sein SHA-256-Hash
// gespeichert. Aus dem Hash laesst sich das Klartext-Token nicht rekonstruieren.

export function randomToken(bytes = 32): string {
  const buf = new Uint8Array(bytes);
  crypto.getRandomValues(buf);
  // base64url ohne Padding — link-sicher.
  let bin = '';
  for (const b of buf) bin += String.fromCharCode(b);
  return btoa(bin).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

export async function sha256Hex(input: string): Promise<string> {
  const data = new TextEncoder().encode(input);
  const digest = await crypto.subtle.digest('SHA-256', data);
  return Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}
