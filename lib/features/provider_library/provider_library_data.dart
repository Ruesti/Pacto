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
  final String cancellationInstructions;
  final String noticePeriod;

  const ProviderTemplate({
    required this.name,
    required this.category,
    required this.provider,
    this.contactPhone,
    this.contactEmail,
    this.contactUrl,
    required this.cancellationMethod,
    required this.cancellationInstructions,
    required this.noticePeriod,
  });
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
    noticePeriod: 'Jederzeit zum Ende des Abrechnungsmonats',
  ),
  ProviderTemplate(
    name: 'Spotify',
    category: ContractCategory.streaming,
    provider: 'Spotify AB',
    contactUrl: 'https://www.spotify.com/de/account/subscription/cancel/',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'Einloggen auf spotify.com → Konto → Premium kündigen.',
    noticePeriod: 'Jederzeit zum Ende des Abrechnungsmonats',
  ),
  ProviderTemplate(
    name: 'Amazon Prime',
    category: ContractCategory.streaming,
    provider: 'Amazon.com Services LLC',
    contactUrl: 'https://www.amazon.de/prime',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'amazon.de → Konto → Prime-Mitgliedschaft → Mitgliedschaft kündigen.',
    noticePeriod: 'Jederzeit, Zugang bis Periodenende',
  ),
  ProviderTemplate(
    name: 'Disney+',
    category: ContractCategory.streaming,
    provider: 'Disney Streaming Services',
    contactUrl: 'https://www.disneyplus.com/',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'disneyplus.com → Konto → Abonnement verwalten → Kündigen.',
    noticePeriod: 'Jederzeit zum Ende des Abrechnungszeitraums',
  ),
  ProviderTemplate(
    name: 'Apple One',
    category: ContractCategory.streaming,
    provider: 'Apple Inc.',
    contactUrl: 'https://appleid.apple.com/',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'Einstellungen → Apple ID → Abonnements → Apple One → Kündigen.',
    noticePeriod: 'Jederzeit zum Ende des Abrechnungszeitraums',
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
    noticePeriod: '30 Tage vor Verlängerungsdatum',
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
    noticePeriod: 'Quartalsweise zum Quartalsende',
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
    noticePeriod: '3 Monate zum Ende der Mindestlaufzeit, dann monatlich',
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
    noticePeriod: '3 Monate zum Ende der Mindestlaufzeit, dann monatlich',
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
    noticePeriod: '3 Monate zum Ende der Mindestlaufzeit',
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
    noticePeriod: '3 Monate zum Ende der Mindestlaufzeit',
  ),
  ProviderTemplate(
    name: 'Telekom MagentaZuhause',
    category: ContractCategory.internet,
    provider: 'Deutsche Telekom AG',
    contactPhone: '0800 330 1000',
    cancellationMethod: CancellationMethod.brief,
    cancellationInstructions:
        'Kündigung schriftlich oder über Mein-Telekom-Portal.',
    noticePeriod: '3 Monate zum Ende der Mindestlaufzeit',
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
    noticePeriod: '1 Monat vor Ablauf (30. November)',
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
    noticePeriod: '3 Monate zum Jahresende (30. September)',
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
    noticePeriod: 'Jederzeit (Jahresplan: Gebühr bis Periodenende)',
  ),
  ProviderTemplate(
    name: 'Microsoft 365',
    category: ContractCategory.software,
    provider: 'Microsoft Corporation',
    contactUrl: 'https://account.microsoft.com/services/',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'account.microsoft.com → Dienste → Microsoft 365 → Abonnement kündigen.',
    noticePeriod: 'Jederzeit, Zugang bis Periodenende',
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
    noticePeriod: '3 Monate zum Monatsende',
  ),
  ProviderTemplate(
    name: 'Spiegel+ Digital',
    category: ContractCategory.zeitung,
    provider: 'SPIEGEL-Verlag Rudolf Augstein GmbH & Co. KG',
    contactEmail: 'abo@spiegel.de',
    contactUrl: 'https://www.spiegel.de/abo/',
    cancellationMethod: CancellationMethod.email,
    cancellationInstructions: 'Kündigung per E-Mail an abo@spiegel.de.',
    noticePeriod: 'Monatlich zum Ende des Abrechnungszeitraums',
  ),
  ProviderTemplate(
    name: 'YouTube Premium',
    category: ContractCategory.streaming,
    provider: 'Google Ireland Limited',
    contactUrl: 'https://www.youtube.com/paid_memberships',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'youtube.com → Konto → Mitgliedschaften → YouTube Premium → Kündigen.',
    noticePeriod: 'Jederzeit zum Ende des Abrechnungszeitraums',
  ),
  ProviderTemplate(
    name: 'Twitch (Turbo/Sub)',
    category: ContractCategory.streaming,
    provider: 'Twitch Interactive, Inc.',
    contactUrl: 'https://www.twitch.tv/settings/subscription',
    cancellationMethod: CancellationMethod.online,
    cancellationInstructions:
        'twitch.tv → Einstellungen → Abonnements → Kündigen.',
    noticePeriod: 'Jederzeit zum Ende des Abrechnungsmonats',
  ),
];
