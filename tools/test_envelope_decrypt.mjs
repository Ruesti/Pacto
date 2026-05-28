// Decrypts a Pacto Maximum-mode envelope using WebCrypto — same code path
// as tools/heir-decrypt.html. Use to verify Dart ↔ browser compatibility.
// Run: node tools/test_envelope_decrypt.mjs '<envelope-json>' '<pin>'

const [, , envJson, pin] = process.argv;
if (!envJson || !pin) {
  console.error('Usage: node test_envelope_decrypt.mjs <envelope-json> <pin>');
  process.exit(1);
}

function b64d(s) {
  return Uint8Array.from(Buffer.from(s, 'base64'));
}

const env = JSON.parse(envJson);
if (env.mode !== 'pin') {
  console.error('Not a Maximum-mode envelope');
  process.exit(1);
}

const salt = b64d(env.salt);
const iv = b64d(env.iv);
const ct = b64d(env.ct);

const baseKey = await crypto.subtle.importKey(
  'raw',
  new TextEncoder().encode(pin),
  { name: 'PBKDF2' },
  false,
  ['deriveKey']
);
const key = await crypto.subtle.deriveKey(
  { name: 'PBKDF2', salt, iterations: 100000, hash: 'SHA-256' },
  baseKey,
  { name: 'AES-GCM', length: 256 },
  false,
  ['decrypt']
);
const plainBuf = await crypto.subtle.decrypt(
  { name: 'AES-GCM', iv, tagLength: 128 },
  key,
  ct
);
console.log(new TextDecoder().decode(plainBuf));
