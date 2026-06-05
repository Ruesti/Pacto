/// Lokale Passwort-Staerke-Heuristik — bewusst ohne externes Paket.
/// Bewertet Laenge und Zeichenklassen und blockt eine kleine Deny-Liste der
/// haeufigsten schwachen Passwoerter.
enum PasswordStrength { weak, medium, strong }

const _denyList = <String>{
  'password',
  'passwort',
  '123456',
  '12345678',
  'qwertz',
  'qwerty',
  'admin',
  'letmein',
  'welcome',
  'iloveyou',
  'abc123',
  '111111',
  '000000',
};

PasswordStrength assessPasswordStrength(String password) {
  if (password.isEmpty) return PasswordStrength.weak;
  if (_denyList.contains(password.toLowerCase())) {
    return PasswordStrength.weak;
  }

  var score = 0;
  if (password.length >= 8) score++;
  if (password.length >= 12) score++;
  if (RegExp(r'[a-z]').hasMatch(password) &&
      RegExp(r'[A-Z]').hasMatch(password)) {
    score++;
  }
  if (RegExp(r'\d').hasMatch(password)) score++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;

  // Sehr kurze Passwoerter koennen nie mehr als "weak" sein.
  if (password.length < 8) return PasswordStrength.weak;
  if (score <= 2) return PasswordStrength.weak;
  if (score <= 3) return PasswordStrength.medium;
  return PasswordStrength.strong;
}
