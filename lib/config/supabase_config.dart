/// Fest eingebaute Supabase-Konfiguration der veroeffentlichten App.
///
/// Der anon-Key ist ein **oeffentlicher** Client-Key und bewusst hier
/// eingebettet: So funktionieren KI-Scan und Cloud-Sync sofort nach der
/// Installation, ohne jede Einrichtung durch den Nutzer.
///
/// Der **geheime** Anthropic-API-Key liegt ausschliesslich serverseitig als
/// Supabase-Secret in der Edge Function `extract-contract` — niemals in der App.
/// Missbrauch wird serverseitig per Rate-Limit (100 Scans/Nutzer/Monat) und
/// Row Level Security begrenzt.
class SupabaseConfig {
  const SupabaseConfig._();

  /// Basis-URL des Pacto-Supabase-Projekts.
  static const String projectUrl = 'https://dxsjgajavgvjlksjawer.supabase.co';

  /// Oeffentlicher anon-Key (JWT) des Projekts.
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR4c2pnYWphdmd2amxrc2phd2VyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkzNTg2NjcsImV4cCI6MjA5NDkzNDY2N30.Mggk35BvteLtTIPeu9TUYx_Pk_IJvr_qMgGFLGk9T84';

  /// Vollstaendige URL der KI-Extraktions-Edge-Function.
  static const String extractFunctionUrl =
      '$projectUrl/functions/v1/extract-contract';
}
