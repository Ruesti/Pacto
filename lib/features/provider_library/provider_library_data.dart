import '../../domain/models/contract_category.dart';
import '../../domain/models/cancellation_method.dart';

class ProviderTemplate {
  final String name;
  final ContractCategory category;
  final String provider;
  final String? contactPhone;
  final String? contactEmail;
  final String? contactUrl;
  final CancellationMethod cancellationMethod;
  // Beschreibende Texte sind primär Deutsch; die *En-Varianten liefern Englisch,
  // wenn die App auf Englisch steht. Fehlt eine Übersetzung, bleibt Deutsch.
  final String cancellationInstructions;
  final String? cancellationInstructionsEn;
  final String noticePeriod;
  final String? noticePeriodEn;
  // Primärdomain ohne Schema/`www.`, z. B. "netflix.com" — wird gegen
  // Uri.parse(url).host gematcht (auch Sub-Domains wie account.netflix.com).
  final String? domain;
  // Zusätzliche Aliase, falls Anbieter mehrere Top-Level-Domains haben
  // (z. B. claude.ai + claude.com + anthropic.com).
  final List<String> domainAliases;

  const ProviderTemplate({
    required this.name,
    required this.category,
    required this.provider,
    this.contactPhone,
    this.contactEmail,
    this.contactUrl,
    required this.cancellationMethod,
    required this.cancellationInstructions,
    this.cancellationInstructionsEn,
    required this.noticePeriod,
    this.noticePeriodEn,
    this.domain,
    this.domainAliases = const [],
  });

  /// Kündigungsanleitung in der App-Sprache (`lang` = ISO-Code, z. B. 'en').
  String cancellationInstructionsFor(String lang) => lang == 'en'
      ? (cancellationInstructionsEn ?? cancellationInstructions)
      : cancellationInstructions;

  /// Kündigungsfrist in der App-Sprache.
  String noticePeriodFor(String lang) =>
      lang == 'en' ? (noticePeriodEn ?? noticePeriod) : noticePeriod;

  Iterable<String> get _allDomains sync* {
    if (domain != null) yield domain!;
    yield* domainAliases;
  }

  bool matchesHost(String normalizedHost) {
    for (final d in _allDomains) {
      if (normalizedHost == d || normalizedHost.endsWith('.$d')) return true;
    }
    return false;
  }
}

/// Findet eine Vorlage zur gegebenen URL anhand der Host-Domain.
/// Akzeptiert sowohl `netflix.com` als auch `www.netflix.com` oder
/// `account.netflix.com` als Treffer für `domain: 'netflix.com'`.
ProviderTemplate? findTemplateForUrl(String url) {
  Uri? uri;
  try {
    uri = Uri.parse(url);
  } catch (_) {
    return null;
  }
  final host = uri.host.toLowerCase();
  if (host.isEmpty) return null;
  final normalized = host.startsWith('www.') ? host.substring(4) : host;
  for (final t in providerLibrary) {
    if (t.matchesHost(normalized)) return t;
  }
  return null;
}

const List<ProviderTemplate> providerLibrary = [
  ProviderTemplate(
    name: 'Netflix',
    category: ContractCategory.streaming,
    provider: 'Netflix International B.V.',
    contactUrl: 'https://www.netflix.com/cancelplan',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'Einloggen auf netflix.com → Konto → Mitgliedschaft kündigen. '
        'Kündigung wirkt zum Ende des aktuellen Abrechnungszeitraums.',
    cancellationInstructionsEn:
        'Sign in at netflix.com → Account → Cancel Membership. '
        'Cancellation takes effect at the end of the current billing period.',
    noticePeriod: 'Jederzeit zum Ende des Abrechnungsmonats',
    noticePeriodEn: 'Anytime, effective end of billing month',
    domain: 'netflix.com',
  ),
  ProviderTemplate(
    name: 'Spotify',
    category: ContractCategory.streaming,
    provider: 'Spotify AB',
    contactUrl: 'https://www.spotify.com/de/account/subscription/cancel/',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'Einloggen auf spotify.com → Konto → Premium kündigen.',
    cancellationInstructionsEn:
        'Sign in at spotify.com → Account → Cancel Premium.',
    noticePeriod: 'Jederzeit zum Ende des Abrechnungsmonats',
    noticePeriodEn: 'Anytime, effective end of billing month',
    domain: 'spotify.com',
  ),
  ProviderTemplate(
    name: 'Amazon Prime',
    category: ContractCategory.streaming,
    provider: 'Amazon.com Services LLC',
    contactUrl: 'https://www.amazon.de/prime',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'amazon.de → Konto → Prime-Mitgliedschaft → Mitgliedschaft kündigen.',
    cancellationInstructionsEn:
        'amazon.de → Account → Prime Membership → Cancel membership.',
    noticePeriod: 'Jederzeit, Zugang bis Periodenende',
    noticePeriodEn: 'Anytime, access until end of period',
    domain: 'amazon.de',
  ),
  ProviderTemplate(
    name: 'Disney+',
    category: ContractCategory.streaming,
    provider: 'Disney Streaming Services',
    contactUrl: 'https://www.disneyplus.com/',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'disneyplus.com → Konto → Abonnement verwalten → Kündigen.',
    cancellationInstructionsEn:
        'disneyplus.com → Account → Manage Subscription → Cancel.',
    noticePeriod: 'Jederzeit zum Ende des Abrechnungszeitraums',
    noticePeriodEn: 'Anytime, effective end of billing period',
    domain: 'disneyplus.com',
  ),
  ProviderTemplate(
    name: 'Apple One',
    category: ContractCategory.streaming,
    provider: 'Apple Inc.',
    contactUrl: 'https://appleid.apple.com/',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'Einstellungen → Apple ID → Abonnements → Apple One → Kündigen.',
    cancellationInstructionsEn:
        'Settings → Apple ID → Subscriptions → Apple One → Cancel.',
    noticePeriod: 'Jederzeit zum Ende des Abrechnungszeitraums',
    noticePeriodEn: 'Anytime, effective end of billing period',
    domain: 'apple.com',
  ),
  ProviderTemplate(
    name: 'DAZN',
    category: ContractCategory.streaming,
    provider: 'Perform Content GmbH',
    contactUrl: 'https://www.dazn.com/de-DE/account',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'dazn.com → Konto → Abonnement → Kündigen. '
        'Kündigung mind. 30 Tage vor Verlängerung.',
    cancellationInstructionsEn:
        'dazn.com → Account → Subscription → Cancel. '
        'Cancel at least 30 days before renewal.',
    noticePeriod: '30 Tage vor Verlängerungsdatum',
    noticePeriodEn: '30 days before renewal date',
    domain: 'dazn.com',
  ),
  ProviderTemplate(
    name: 'ARD ZDF Deutschlandradio (GEZ)',
    category: ContractCategory.sonstiges,
    provider: 'Beitragsservice',
    contactPhone: '01806 999 555 10',
    contactUrl: 'https://www.rundfunkbeitrag.de/',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'rundfunkbeitrag.de → Formulare → Abmeldung. '
        'Alternativ Brief an: Beitragsservice, 50656 Köln.',
    cancellationInstructionsEn:
        'rundfunkbeitrag.de → Forms → Deregistration (Abmeldung). '
        'Alternatively, send a letter to: Beitragsservice, 50656 Köln.',
    noticePeriod: 'Quartalsweise zum Quartalsende',
    noticePeriodEn: 'Quarterly, effective end of quarter',
    domain: 'rundfunkbeitrag.de',
  ),
  ProviderTemplate(
    name: 'Telekom MagentaMobil',
    category: ContractCategory.handy,
    provider: 'Deutsche Telekom AG',
    contactPhone: '0800 330 1000',
    contactUrl: 'https://www.telekom.de/',
    cancellationMethod: CancellationMethod.brief,
    cancellationInstructions:
        'Kündigung schriftlich per Brief oder über Mein-Telekom-Portal. '
        'Adresse: Telekom Deutschland GmbH, 53172 Bonn.',
    cancellationInstructionsEn:
        'Cancel in writing by letter or via the Mein Telekom portal. '
        'Address: Telekom Deutschland GmbH, 53172 Bonn.',
    noticePeriod: '3 Monate zum Ende der Mindestlaufzeit, dann monatlich',
    noticePeriodEn: '3 months before end of minimum term, then monthly',
    domain: 'telekom.de',
  ),
  ProviderTemplate(
    name: 'Vodafone Mobilfunk',
    category: ContractCategory.handy,
    provider: 'Vodafone GmbH',
    contactPhone: '0800 172 1212',
    contactUrl: 'https://www.vodafone.de/',
    cancellationMethod: CancellationMethod.brief,
    cancellationInstructions:
        'Kündigung per Brief: Vodafone GmbH, 40547 Düsseldorf. '
        'Oder über MeinVodafone-App/Portal.',
    cancellationInstructionsEn:
        'Cancel by letter: Vodafone GmbH, 40547 Düsseldorf. '
        'Or via the MeinVodafone app/portal.',
    noticePeriod: '3 Monate zum Ende der Mindestlaufzeit, dann monatlich',
    noticePeriodEn: '3 months before end of minimum term, then monthly',
    domain: 'vodafone.de',
  ),
  ProviderTemplate(
    name: 'O2 Mobilfunk',
    category: ContractCategory.handy,
    provider: 'Telefónica Germany GmbH & Co. OHG',
    contactPhone: '0800 505 0155',
    contactUrl: 'https://www.o2online.de/',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'Mein O2 → Vertrag → Kündigen. '
        'Oder Brief: Telefónica Germany, 90345 Nürnberg.',
    cancellationInstructionsEn:
        'Mein O2 → Contract → Cancel. '
        'Or by letter: Telefónica Germany, 90345 Nürnberg.',
    noticePeriod: '3 Monate zum Ende der Mindestlaufzeit',
    noticePeriodEn: '3 months before end of minimum term',
    domain: 'o2online.de',
  ),
  ProviderTemplate(
    name: '1&1 DSL',
    category: ContractCategory.internet,
    provider: '1&1 Telecom GmbH',
    contactPhone: '0721 9600',
    contactUrl: 'https://www.1und1.de/',
    cancellationMethod: CancellationMethod.brief,
    cancellationInstructions:
        'Kündigung per Brief: 1&1 Telecom GmbH, 56203 Höhr-Grenzhausen.',
    cancellationInstructionsEn:
        'Cancel by letter: 1&1 Telecom GmbH, 56203 Höhr-Grenzhausen.',
    noticePeriod: '3 Monate zum Ende der Mindestlaufzeit',
    noticePeriodEn: '3 months before end of minimum term',
    domain: '1und1.de',
  ),
  ProviderTemplate(
    name: 'Telekom MagentaZuhause',
    category: ContractCategory.internet,
    provider: 'Deutsche Telekom AG',
    contactPhone: '0800 330 1000',
    contactUrl: 'https://www.telekom.de/hilfe/festnetz-internet/vertrag/kuendigung',
    cancellationMethod: CancellationMethod.brief,
    cancellationInstructions:
        'Kündigung schriftlich oder über Mein-Telekom-Portal.',
    cancellationInstructionsEn:
        'Cancel in writing or via the Mein Telekom portal.',
    noticePeriod: '3 Monate zum Ende der Mindestlaufzeit',
    noticePeriodEn: '3 months before end of minimum term',
  ),
  ProviderTemplate(
    name: 'HUK-COBURG Kfz-Versicherung',
    category: ContractCategory.versicherung,
    provider: 'HUK-COBURG',
    contactPhone: '0800 2153622',
    contactEmail: 'info@huk-coburg.de',
    contactUrl: 'https://www.huk.de/',
    cancellationMethod: CancellationMethod.brief,
    cancellationInstructions:
        'Kündigung per Brief bis 30. November: HUK-COBURG, 96444 Coburg.',
    cancellationInstructionsEn:
        'Cancel by letter by 30 November: HUK-COBURG, 96444 Coburg.',
    noticePeriod: '1 Monat vor Ablauf (30. November)',
    noticePeriodEn: '1 month before expiry (30 November)',
    domain: 'huk.de',
  ),
  ProviderTemplate(
    name: 'ADAC Mitgliedschaft',
    category: ContractCategory.sonstiges,
    provider: 'ADAC e.V.',
    contactPhone: '0800 5101112',
    contactUrl: 'https://www.adac.de/',
    cancellationMethod: CancellationMethod.brief,
    cancellationInstructions:
        'Kündigung per Brief oder E-Mail an den zuständigen Regionalclub.',
    cancellationInstructionsEn:
        'Cancel by letter or email to your responsible regional club.',
    noticePeriod: '3 Monate zum Jahresende (30. September)',
    noticePeriodEn: '3 months before year end (30 September)',
    domain: 'adac.de',
  ),
  ProviderTemplate(
    name: 'Adobe Creative Cloud',
    category: ContractCategory.software,
    provider: 'Adobe Systems Software Ireland Ltd.',
    contactUrl: 'https://www.adobe.com/de/account.html',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'adobe.com → Konto → Plan verwalten → Abo kündigen. '
        'Jahresmitgliedschaft: Gebühr für vorzeitige Kündigung beachten.',
    cancellationInstructionsEn:
        'adobe.com → Account → Manage plan → Cancel plan. '
        'Annual plan: note the early termination fee.',
    noticePeriod: 'Jederzeit (Jahresplan: Gebühr bis Periodenende)',
    noticePeriodEn: 'Anytime (annual plan: fee until end of period)',
    domain: 'adobe.com',
  ),
  ProviderTemplate(
    name: 'Microsoft 365',
    category: ContractCategory.software,
    provider: 'Microsoft Corporation',
    contactUrl: 'https://account.microsoft.com/services/',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'account.microsoft.com → Dienste → Microsoft 365 → Abonnement kündigen.',
    cancellationInstructionsEn:
        'account.microsoft.com → Services → Microsoft 365 → Cancel subscription.',
    noticePeriod: 'Jederzeit, Zugang bis Periodenende',
    noticePeriodEn: 'Anytime, access until end of period',
    domain: 'microsoft.com',
  ),
  ProviderTemplate(
    name: 'McFit Fitnessstudio',
    category: ContractCategory.fitness,
    provider: 'RSG Group GmbH',
    contactPhone: '030 8894170',
    contactUrl: 'https://www.mcfit.com/',
    cancellationMethod: CancellationMethod.brief,
    cancellationInstructions:
        'Kündigung per eingeschriebenem Brief an das Studio mit Mitgliedsnummer.',
    cancellationInstructionsEn:
        'Cancel by registered letter to the studio, including your membership number.',
    noticePeriod: '3 Monate zum Monatsende',
    noticePeriodEn: '3 months, effective end of month',
    domain: 'mcfit.com',
  ),
  ProviderTemplate(
    name: 'Spiegel+ Digital',
    category: ContractCategory.zeitung,
    provider: 'SPIEGEL-Verlag Rudolf Augstein GmbH & Co. KG',
    contactEmail: 'abo@spiegel.de',
    contactUrl: 'https://www.spiegel.de/abo/',
    cancellationMethod: CancellationMethod.email,
    cancellationInstructions: 'Kündigung per E-Mail an abo@spiegel.de.',
    cancellationInstructionsEn: 'Cancel by email to abo@spiegel.de.',
    noticePeriod: 'Monatlich zum Ende des Abrechnungszeitraums',
    noticePeriodEn: 'Monthly, effective end of billing period',
    domain: 'spiegel.de',
  ),
  ProviderTemplate(
    name: 'YouTube Premium',
    category: ContractCategory.streaming,
    provider: 'Google Ireland Limited',
    contactUrl: 'https://www.youtube.com/paid_memberships',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'youtube.com → Konto → Mitgliedschaften → YouTube Premium → Kündigen.',
    cancellationInstructionsEn:
        'youtube.com → Account → Memberships → YouTube Premium → Cancel.',
    noticePeriod: 'Jederzeit zum Ende des Abrechnungszeitraums',
    noticePeriodEn: 'Anytime, effective end of billing period',
    domain: 'youtube.com',
  ),
  ProviderTemplate(
    name: 'Twitch (Turbo/Sub)',
    category: ContractCategory.streaming,
    provider: 'Twitch Interactive, Inc.',
    contactUrl: 'https://www.twitch.tv/settings/subscription',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'twitch.tv → Einstellungen → Abonnements → Kündigen.',
    cancellationInstructionsEn:
        'twitch.tv → Settings → Subscriptions → Cancel.',
    noticePeriod: 'Jederzeit zum Ende des Abrechnungsmonats',
    noticePeriodEn: 'Anytime, effective end of billing month',
    domain: 'twitch.tv',
  ),
  // ─── SaaS / AI / Productivity ─────────────────────────────────────────
  ProviderTemplate(
    name: 'Claude (Anthropic)',
    category: ContractCategory.software,
    provider: 'Anthropic, PBC',
    contactEmail: 'support@anthropic.com',
    contactUrl: 'https://claude.ai/settings/billing',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'claude.ai → Einstellungen → Abrechnung → Plan verwalten → Kündigen.',
    cancellationInstructionsEn:
        'claude.ai → Settings → Billing → Manage plan → Cancel.',
    noticePeriod: 'Monatlich zum Ende des Abrechnungszeitraums',
    noticePeriodEn: 'Monthly, effective end of billing period',
    domain: 'claude.ai',
    domainAliases: ['claude.com', 'anthropic.com'],
  ),
  ProviderTemplate(
    name: 'ChatGPT (OpenAI)',
    category: ContractCategory.software,
    provider: 'OpenAI, L.L.C.',
    contactEmail: 'support@openai.com',
    contactUrl: 'https://chatgpt.com/#settings/Subscription',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'chatgpt.com → Einstellungen → Abonnement → Mein Abo verwalten → Kündigen.',
    cancellationInstructionsEn:
        'chatgpt.com → Settings → Subscription → Manage my subscription → Cancel.',
    noticePeriod: 'Monatlich zum Ende des Abrechnungszeitraums',
    noticePeriodEn: 'Monthly, effective end of billing period',
    domain: 'openai.com',
    domainAliases: ['chatgpt.com', 'chat.openai.com'],
  ),
  ProviderTemplate(
    name: 'GitHub Copilot',
    category: ContractCategory.software,
    provider: 'GitHub, Inc.',
    contactUrl: 'https://github.com/settings/billing',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'github.com → Settings → Billing and plans → Plans → Copilot → Cancel.',
    cancellationInstructionsEn:
        'github.com → Settings → Billing and plans → Plans → Copilot → Cancel.',
    noticePeriod: 'Monatlich zum Ende des Abrechnungszeitraums',
    noticePeriodEn: 'Monthly, effective end of billing period',
    domain: 'github.com',
  ),
  ProviderTemplate(
    name: 'Notion',
    category: ContractCategory.software,
    provider: 'Notion Labs, Inc.',
    contactEmail: 'team@makenotion.com',
    contactUrl: 'https://www.notion.so/my-account',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'notion.so → Einstellungen → Plans → Downgrade auf Free.',
    cancellationInstructionsEn:
        'notion.so → Settings → Plans → Downgrade to Free.',
    noticePeriod: 'Jederzeit, Zugang bis Periodenende',
    noticePeriodEn: 'Anytime, access until end of period',
    domain: 'notion.so',
  ),
  ProviderTemplate(
    name: 'Figma',
    category: ContractCategory.software,
    provider: 'Figma, Inc.',
    contactEmail: 'support@figma.com',
    contactUrl: 'https://www.figma.com/settings/billing',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'figma.com → Settings → Plans & billing → Cancel plan.',
    cancellationInstructionsEn:
        'figma.com → Settings → Plans & billing → Cancel plan.',
    noticePeriod: 'Jederzeit zum Ende des Abrechnungszeitraums',
    noticePeriodEn: 'Anytime, effective end of billing period',
    domain: 'figma.com',
  ),
  ProviderTemplate(
    name: 'Slack',
    category: ContractCategory.software,
    provider: 'Slack Technologies, LLC',
    contactUrl: 'https://app.slack.com/admin/billing',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'slack.com → Einstellungen → Abrechnung → Abo kündigen.',
    cancellationInstructionsEn:
        'slack.com → Settings → Billing → Cancel subscription.',
    noticePeriod: 'Jederzeit zum Ende des Abrechnungszeitraums',
    noticePeriodEn: 'Anytime, effective end of billing period',
    domain: 'slack.com',
  ),
  ProviderTemplate(
    name: 'Zoom',
    category: ContractCategory.software,
    provider: 'Zoom Video Communications, Inc.',
    contactUrl: 'https://zoom.us/billing',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'zoom.us → Profil → Abrechnung → Aktuelle Pläne → Abo kündigen.',
    cancellationInstructionsEn:
        'zoom.us → Profile → Billing → Current Plans → Cancel subscription.',
    noticePeriod: 'Monatlich zum Ende des Abrechnungszeitraums',
    noticePeriodEn: 'Monthly, effective end of billing period',
    domain: 'zoom.us',
  ),
  ProviderTemplate(
    name: 'Dropbox',
    category: ContractCategory.software,
    provider: 'Dropbox International Unlimited Company',
    contactUrl: 'https://www.dropbox.com/account/plan',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'dropbox.com → Konto → Plan → Plan kündigen.',
    cancellationInstructionsEn:
        'dropbox.com → Account → Plan → Cancel plan.',
    noticePeriod: 'Jederzeit zum Ende des Abrechnungszeitraums',
    noticePeriodEn: 'Anytime, effective end of billing period',
    domain: 'dropbox.com',
  ),
  ProviderTemplate(
    name: 'Canva Pro',
    category: ContractCategory.software,
    provider: 'Canva Pty Ltd',
    contactUrl: 'https://www.canva.com/settings/billing-and-plans',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'canva.com → Konto → Abrechnung & Pläne → Pro Plan → Testversion kündigen / Abo beenden.',
    cancellationInstructionsEn:
        'canva.com → Account → Billing & plans → Pro plan → Cancel trial / end subscription.',
    noticePeriod: 'Jederzeit, Zugang bis Periodenende',
    noticePeriodEn: 'Anytime, access until end of period',
    domain: 'canva.com',
  ),
  ProviderTemplate(
    name: 'LinkedIn Premium',
    category: ContractCategory.software,
    provider: 'LinkedIn Ireland Unlimited Company',
    contactUrl: 'https://www.linkedin.com/premium/manage/',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'linkedin.com → Mich → Premium-Konto → Premium kündigen.',
    cancellationInstructionsEn:
        'linkedin.com → Me → Premium account → Cancel Premium.',
    noticePeriod: 'Jederzeit zum Ende des Abrechnungszeitraums',
    noticePeriodEn: 'Anytime, effective end of billing period',
    domain: 'linkedin.com',
  ),
  ProviderTemplate(
    name: 'Audible',
    category: ContractCategory.streaming,
    provider: 'Audible GmbH',
    contactPhone: '0800 222 0014',
    contactUrl: 'https://www.audible.de/account/membershipdetails',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'audible.de → Konto → Mitgliedschaftsdetails → Mitgliedschaft beenden.',
    cancellationInstructionsEn:
        'audible.de → Account → Membership details → End membership.',
    noticePeriod: 'Jederzeit zum Ende des Abrechnungszeitraums',
    noticePeriodEn: 'Anytime, effective end of billing period',
    domain: 'audible.de',
  ),
  ProviderTemplate(
    name: 'Apple iCloud+',
    category: ContractCategory.software,
    provider: 'Apple Inc.',
    contactUrl: 'https://www.icloud.com/',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'Einstellungen → Apple ID → iCloud → Speicher → Speicherplan ändern → Downgrade.',
    cancellationInstructionsEn:
        'Settings → Apple ID → iCloud → Storage → Change Storage Plan → Downgrade.',
    noticePeriod: 'Jederzeit zum Ende des Abrechnungszeitraums',
    noticePeriodEn: 'Anytime, effective end of billing period',
    domain: 'icloud.com',
  ),
  ProviderTemplate(
    name: 'Google One',
    category: ContractCategory.software,
    provider: 'Google Ireland Limited',
    contactUrl: 'https://one.google.com/billing',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'one.google.com → Einstellungen → Abo verwalten → Abo kündigen.',
    cancellationInstructionsEn:
        'one.google.com → Settings → Manage subscription → Cancel subscription.',
    noticePeriod: 'Jederzeit zum Ende des Abrechnungszeitraums',
    noticePeriodEn: 'Anytime, effective end of billing period',
    domain: 'google.com',
  ),
  ProviderTemplate(
    name: 'PlayStation Plus',
    category: ContractCategory.streaming,
    provider: 'Sony Interactive Entertainment Network Europe Ltd.',
    contactUrl: 'https://www.playstation.com/de-de/playstation-plus/',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'PlayStation Store → Konto → Abonnements → PS Plus → Automatische Verlängerung deaktivieren.',
    cancellationInstructionsEn:
        'PlayStation Store → Account → Subscriptions → PS Plus → Turn off auto-renewal.',
    noticePeriod: 'Jederzeit (deaktivieren der Verlängerung)',
    noticePeriodEn: 'Anytime (turn off auto-renewal)',
    domain: 'playstation.com',
  ),
  ProviderTemplate(
    name: 'Xbox Game Pass',
    category: ContractCategory.streaming,
    provider: 'Microsoft Corporation',
    contactUrl: 'https://account.microsoft.com/services/',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'account.microsoft.com → Dienste & Abonnements → Game Pass → Kündigen.',
    cancellationInstructionsEn:
        'account.microsoft.com → Services & subscriptions → Game Pass → Cancel.',
    noticePeriod: 'Jederzeit zum Ende des Abrechnungszeitraums',
    noticePeriodEn: 'Anytime, effective end of billing period',
    domain: 'xbox.com',
  ),
];
