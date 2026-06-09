// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Pacto';

  @override
  String get saveButton => 'Speichern';

  @override
  String get cancelButton => 'Abbrechen';

  @override
  String get deleteButton => 'Löschen';

  @override
  String get retryButton => 'Erneut versuchen';

  @override
  String errorMessage(String error) {
    return 'Fehler: $error';
  }

  @override
  String get daysExpired => 'abgelaufen';

  @override
  String get daysToday => 'heute';

  @override
  String get daysTomorrow => 'morgen';

  @override
  String daysIn(int days) {
    return 'in $days Tagen';
  }

  @override
  String get catStreaming => 'Streaming';

  @override
  String get catVersicherung => 'Versicherung';

  @override
  String get catHandy => 'Handy';

  @override
  String get catInternet => 'Internet';

  @override
  String get catSoftware => 'Software';

  @override
  String get catFitness => 'Fitness';

  @override
  String get catZeitung => 'Zeitung / Medien';

  @override
  String get catSonstiges => 'Sonstiges';

  @override
  String get accessCatRouter => 'Router / WLAN';

  @override
  String get accessCatSmarthome => 'Smart Home';

  @override
  String get accessCatEmail => 'E-Mail / Konto';

  @override
  String get accessCatBanking => 'Banking';

  @override
  String get accessCatServer => 'Server / NAS';

  @override
  String get accessCatPartnerAccount => 'Partner-Zugang';

  @override
  String get accessCatGeraet => 'Gerät';

  @override
  String get accessCatSonstiges => 'Sonstiges';

  @override
  String get entryAccess => 'Zugang anlegen';

  @override
  String get entryAccessSubtitle =>
      'Login ohne Vertrag (Router, Server, Partner …)';

  @override
  String get addAccessTitle => 'Zugang hinzufügen';

  @override
  String get editAccessTitle => 'Zugang bearbeiten';

  @override
  String get accessesTitle => 'Zugänge';

  @override
  String get segmentContracts => 'Verträge';

  @override
  String get segmentAccesses => 'Zugänge';

  @override
  String get fieldAccessCategory => 'Art des Zugangs';

  @override
  String get noAccessesTitle => 'Noch keine Zugänge';

  @override
  String get noAccessesDefault =>
      'Lege Zugänge an, die deine Erben brauchen:\nRouter, Server, E-Mail-Konto.';

  @override
  String get settingsVerification => 'Passwort-Prüfungen';

  @override
  String get settingsVerificationSubtitle =>
      'Erinnerung, Datenleck-Check, Stärke';

  @override
  String get verifyTitle => 'Passwort-Prüfungen';

  @override
  String get verifyIntro =>
      'Wähle, wie Pacto dir hilft, gespeicherte Logins aktuell und sicher zu halten. Alles ist optional und läuft auf deinem Gerät.';

  @override
  String get verifyManualReminder => 'Bestätigungs-Erinnerung';

  @override
  String get verifyManualReminderSubtitle =>
      'Markiert Logins, die du länger nicht bestätigt hast';

  @override
  String get verifyReminderInterval => 'Erinnerungs-Intervall';

  @override
  String verifyReminderMonths(int months) {
    return '$months Monate';
  }

  @override
  String get verifyBreachCheck => 'Datenleck-Prüfung';

  @override
  String get verifyBreachCheckSubtitle =>
      'Über HaveIBeenPwned — nur ein Hash-Präfix verlässt das Gerät';

  @override
  String get verifyStrengthCheck => 'Passwort-Stärke';

  @override
  String get verifyStrengthCheckSubtitle =>
      'Zeigt eine Stärke-Einschätzung beim Aufdecken an';

  @override
  String get breachCheckButton => 'Auf Datenleck prüfen';

  @override
  String get breachChecking => 'Prüfe …';

  @override
  String get breachClean => 'In keinem bekannten Datenleck gefunden';

  @override
  String breachFound(int count) {
    return 'In $count Datenlecks gefunden — ändere dieses Passwort';
  }

  @override
  String get breachError => 'Prüfung fehlgeschlagen — später erneut versuchen';

  @override
  String get strengthLabel => 'Stärke';

  @override
  String get strengthWeak => 'Schwach';

  @override
  String get strengthMedium => 'Mittel';

  @override
  String get strengthStrong => 'Stark';

  @override
  String get verifyReminderBannerTitle => 'Logins bestätigen';

  @override
  String verifyReminderBannerBody(int count) {
    return '$count gespeicherte Logins sind länger nicht bestätigt worden.';
  }

  @override
  String get settingsAppLock => 'App-Sperre';

  @override
  String get settingsAppLockSubtitle => 'Biometrie & PIN beim Öffnen';

  @override
  String get appLockTitle => 'App-Sperre';

  @override
  String get appLockEnable => 'App-Sperre aktiv';

  @override
  String get appLockEnableSubtitle =>
      'Beim Öffnen Biometrie oder PIN verlangen';

  @override
  String get appLockChangePin => 'PIN ändern';

  @override
  String get appLockBiometricReveal => 'Beim Aufdecken erneut prüfen';

  @override
  String get appLockBiometricRevealSubtitle =>
      'Biometrie/PIN, bevor Passwörter sichtbar werden';

  @override
  String get appLockPinPrompt => 'PIN';

  @override
  String get appLockSetPinTitle => 'PIN festlegen';

  @override
  String get appLockConfirmPinTitle => 'PIN bestätigen';

  @override
  String get appLockPinTooShort => 'Mindestens 4 Ziffern';

  @override
  String get appLockPinMismatch => 'PINs stimmen nicht überein';

  @override
  String get lockScreenTitle => 'Pacto entsperren';

  @override
  String get lockUnlockButton => 'Entsperren';

  @override
  String get lockUseBiometrics => 'Biometrie verwenden';

  @override
  String get lockWrongPin => 'Falscher PIN';

  @override
  String get lockReason => 'Entsperre Pacto';

  @override
  String get revealReason => 'Passwort aufdecken';

  @override
  String get billingMonthly => 'Monatlich';

  @override
  String get billingQuarterly => 'Vierteljährlich';

  @override
  String get billingYearly => 'Jährlich';

  @override
  String get billingWeekly => 'Wöchentlich';

  @override
  String get cancBrief => 'Brief';

  @override
  String get cancOnline => 'Online';

  @override
  String get cancTelefon => 'Telefon';

  @override
  String get cancEmail => 'E-Mail';

  @override
  String get cancAutomatisch => 'Automatisch (kein Handlungsbedarf)';

  @override
  String get accessVollzugang => 'Vollzugang (alle Felder)';

  @override
  String get accessNurListe => 'Nur Liste (Name, Kosten, Kündigung)';

  @override
  String get searchHint => 'Suche nach Name oder Anbieter…';

  @override
  String get addContractFab => 'Vertrag';

  @override
  String get filterAll => 'Alle';

  @override
  String get noContractsTitle => 'Noch keine Verträge';

  @override
  String get noContractsDefault =>
      'Füge deinen ersten Vertrag hinzu.\nWeißt du wirklich was du zahlst?';

  @override
  String noContractsSearch(String query) {
    return 'Kein Vertrag gefunden für \"$query\"';
  }

  @override
  String get noContractsCategory => 'Kein Vertrag in dieser Kategorie';

  @override
  String get sortByTitle => 'Sortieren nach';

  @override
  String get sortCost => 'Kosten (höchste zuerst)';

  @override
  String get sortName => 'Name (A–Z)';

  @override
  String get sortCategory => 'Kategorie';

  @override
  String get sortRenewal => 'Nächste Verlängerung';

  @override
  String dashboardGreeting(String name) {
    return 'Hallo $name 👋';
  }

  @override
  String get dashboardGreetingAnon => 'Hallo 👋';

  @override
  String get dashboardSubtitle =>
      'Deine Verträge. Deine Übersicht. Für deine Liebsten.';

  @override
  String get sectionOverview => 'Übersicht';

  @override
  String get sectionYourContracts => 'Deine Verträge';

  @override
  String get sectionShowAll => 'Alle anzeigen';

  @override
  String get statContracts => 'Verträge';

  @override
  String get statContractsHint => 'aktiv';

  @override
  String get statCancellations => 'Kündigungen';

  @override
  String get statCancellationsHint => 'nächste 30 Tage';

  @override
  String get statSubscriptions => 'Abos';

  @override
  String get statSubscriptionsHint => 'aktiv';

  @override
  String get statHeirs => 'Erben';

  @override
  String get statHeirsHint => 'hinterlegt';

  @override
  String get emergencyLabel => 'Für den Notfall';

  @override
  String get emergencyHeadlineNotified => 'Deine Erben sind informiert';

  @override
  String get emergencyBodyNotified =>
      'Im Ernstfall werden deine Erben benachrichtigt und erhalten Zugriff auf deine Vertragsübersicht.';

  @override
  String get emergencyHeadlineEmpty => 'Noch niemand hinterlegt';

  @override
  String get emergencyBodyEmpty =>
      'Lege fest, wer im Fall der Fälle Zugang zu deinen Verträgen erhält.';

  @override
  String get emergencyAction => 'Erben verwalten';

  @override
  String get navOverview => 'Übersicht';

  @override
  String get navContracts => 'Verträge';

  @override
  String get navAdd => 'Hinzufügen';

  @override
  String get navHeirs => 'Erben';

  @override
  String get navMore => 'Mehr';

  @override
  String nextPayment(String date) {
    return 'Nächste Zahlung: $date';
  }

  @override
  String get perMonthSuffix => '/ Monat';

  @override
  String get perQuarterSuffix => '/ Quartal';

  @override
  String get perYearSuffix => '/ Jahr';

  @override
  String get perWeekSuffix => '/ Woche';

  @override
  String get monthlyCosts => 'Monatliche Ausgaben';

  @override
  String perYear(String amount) {
    return '$amount pro Jahr';
  }

  @override
  String contractsLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Verträge',
      one: 'Vertrag',
    );
    return '$_temp0';
  }

  @override
  String get addContractTitle => 'Vertrag hinzufügen';

  @override
  String get editContractTitle => 'Vertrag bearbeiten';

  @override
  String get updateButton => 'Aktualisieren';

  @override
  String get sectionBasic => 'Basisdaten';

  @override
  String get sectionCost => 'Kosten';

  @override
  String get sectionCancellation => 'Kündigung';

  @override
  String get sectionContact => 'Kontakt';

  @override
  String get sectionDuration => 'Laufzeit';

  @override
  String get sectionNotes => 'Notizen';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldAccessName => 'Name / Bezeichnung';

  @override
  String get fieldProvider => 'Anbieter';

  @override
  String get kindVertrag => 'Vertrag';

  @override
  String get kindAbo => 'Abo';

  @override
  String get fieldCategory => 'Kategorie';

  @override
  String get fieldAmount => 'Betrag (€)';

  @override
  String get fieldCycle => 'Zyklus';

  @override
  String get fieldCancellationMethod => 'Methode';

  @override
  String get fieldNoticePeriod => 'Kündigungsfrist';

  @override
  String get fieldNoticePeriodHint => 'z. B. \"3 Monate zum Quartalsende\"';

  @override
  String get fieldCancellationInstructions => 'Kündigungsanleitung';

  @override
  String get fieldPhone => 'Telefon';

  @override
  String get fieldEmail => 'E-Mail';

  @override
  String get fieldWebsite => 'Website';

  @override
  String get fieldContractStart => 'Vertragsbeginn';

  @override
  String get fieldNextRenewal => 'Nächste Verlängerung';

  @override
  String get fieldNotesHint => 'Besonderheiten, Sonderkündigungsrecht…';

  @override
  String get validationNameRequired => 'Name ist erforderlich';

  @override
  String get validationProviderRequired => 'Anbieter ist erforderlich';

  @override
  String get validationEmailRequired => 'E-Mail ist erforderlich';

  @override
  String get validationPinTooShort => 'PIN muss mind. 6 Ziffern haben';

  @override
  String get pickDate => 'Datum wählen';

  @override
  String get confidenceHigh =>
      'KI-Extraktion erfolgreich. Bitte prüfe die übernommenen Angaben.';

  @override
  String get confidenceMedium =>
      'Einige Felder sind unsicher. Bitte sorgfältig prüfen.';

  @override
  String get confidenceLow =>
      'Nur wenige Felder erkannt. Bitte alle Angaben prüfen oder erneut scannen.';

  @override
  String get entrySheetTitle => 'Vertrag hinzufügen';

  @override
  String get entryLibrary => 'Aus Bibliothek wählen';

  @override
  String get entryLibrarySubtitle => 'Netflix, Spotify, Telekom & mehr';

  @override
  String get entryManual => 'Manuell eingeben';

  @override
  String get entryManualSubtitle => 'Alle Felder selbst ausfüllen';

  @override
  String get entryScan => 'Dokument scannen (KI)';

  @override
  String get entryScanSubtitle => 'Foto oder PDF → automatisch ausfüllen';

  @override
  String get entryWebSearch => 'Online-Vertrag suchen (KI)';

  @override
  String get entryWebSearchSubtitle =>
      'Webseite des Anbieters → automatisch ausfüllen';

  @override
  String get scanTitle => 'Dokument scannen';

  @override
  String get scanChooseSource => 'Wähle eine Quelle';

  @override
  String get scanHint => 'Die KI extrahiert automatisch Vertragsdetails.';

  @override
  String get scanFromCamera => 'Mit Kamera aufnehmen';

  @override
  String get scanFromGallery => 'Foto aus Galerie';

  @override
  String get scanFromFile => 'Datei / PDF auswählen';

  @override
  String get scanLoading => 'KI analysiert Dokument…';

  @override
  String get shareImportTitleUrl => 'Webseite analysieren';

  @override
  String get shareImportTitleFile => 'Geteiltes Dokument';

  @override
  String get shareImportLoadingUrl => 'KI analysiert die Webseite…';

  @override
  String get shareImportLoadingFile => 'KI analysiert das geteilte Dokument…';

  @override
  String get createManually => 'Manuell anlegen';

  @override
  String get webSearchHint => 'Suche oder URL eingeben';

  @override
  String get webSearchImportButton => 'Übernehmen';

  @override
  String get webSearchImportTooltip => 'Diese Seite per KI auswerten';

  @override
  String get urlProcessingTitle => 'Seite analysieren';

  @override
  String get urlProcessingLoading => 'KI analysiert die Webseite…';

  @override
  String get contractNotFound => 'Vertrag nicht gefunden';

  @override
  String get contactSectionTitle => 'Kontakt';

  @override
  String get notesSectionTitle => 'Notizen';

  @override
  String get contractStartLabel => 'Beginn';

  @override
  String get renewalLabel => 'Verlängerung';

  @override
  String get deleteContractTitle => 'Vertrag löschen?';

  @override
  String deleteContractContent(String name) {
    return '\"$name\" wirklich dauerhaft löschen?';
  }

  @override
  String get cancellationCardTitle => 'Kündigung';

  @override
  String get cancellationMethodLabel => 'Methode';

  @override
  String get cancellationPeriodLabel => 'Frist';

  @override
  String get cancellationRenewalLabel => 'Nächste Verlängerung';

  @override
  String get cancellationInstructionsLabel => 'Anleitung:';

  @override
  String get heirsTitle => 'Erben & Teilen';

  @override
  String get heirsInfoText =>
      'Hinterbliebene erhalten Zugang zu deinen Verträgen. Für den Fall der Fälle.';

  @override
  String get heirsEmptyTitle => 'Noch keine Erben hinterlegt';

  @override
  String get heirsEmptySubtitle =>
      'Lege fest, wer im Fall der Fälle Zugang\nzu deinen Verträgen erhält.';

  @override
  String get heirAddFab => 'Erbe hinzufügen';

  @override
  String get exportPdfTooltip => 'PDF exportieren';

  @override
  String exportedPath(String path) {
    return 'Exportiert: $path';
  }

  @override
  String get noContractsToExport => 'Keine Verträge zum Exportieren';

  @override
  String get deleteHeirTitle => 'Erbe löschen?';

  @override
  String deleteHeirContent(String name) {
    return '$name wirklich entfernen?';
  }

  @override
  String get heirEditTitle => 'Erbe bearbeiten';

  @override
  String get heirAddTitle => 'Erbe hinzufügen';

  @override
  String get fieldPin => 'PIN setzen';

  @override
  String get fieldPinEdit => 'Neuen PIN setzen (optional)';

  @override
  String get fieldPinHelper => 'Mind. 6 Ziffern';

  @override
  String get fieldAccessLevel => 'Zugangsstufe';

  @override
  String get accessLevelsTitle => 'Zugangsstufen erklärt:';

  @override
  String get premiumDialogTitle => 'Vollzugang freischalten';

  @override
  String get premiumDialogContent =>
      'Du hast die kostenlose Grenze von 5 Verträgen erreicht.\n\nMit dem Vollzugang verwaltest du beliebig viele Verträge — einmaliger Kauf, kein Abo.\n\nIm finalen Release: ~2,99 €';

  @override
  String get premiumLater => 'Später';

  @override
  String get premiumUnlock => 'Jetzt kaufen';

  @override
  String get premiumPurchaseFailed =>
      'Kauf fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSectionData => 'Daten & Sync';

  @override
  String get settingsCloudSync => 'Cloud-Sync (Supabase)';

  @override
  String get settingsCloudSyncSubtitle => 'Verschlüsseltes Backup, AES-256';

  @override
  String get settingsVault => 'Lebenszeichen-Tresor';

  @override
  String get settingsVaultSubtitle => 'Automatische Weitergabe an Erben';

  @override
  String get settingsHeirPasswordPolicy => 'Login-Daten für Erben';

  @override
  String get settingsHeirPasswordPolicySubtitle =>
      'Wie kommen Erben an Benutzernamen und Passwörter?';

  @override
  String get heirPolicyTitle => 'Login-Daten für Erben';

  @override
  String get heirPolicyIntro =>
      'Pacto kann pro Vertrag Benutzername und Passwort speichern, damit deine Erben im Ernstfall direkt kündigen können. Wähle, wie diese Daten geschützt werden — du kannst die Auswahl jederzeit ändern.';

  @override
  String get heirPolicyNoneTitle => 'Keine Passwörter speichern';

  @override
  String get heirPolicyNoneBody =>
      'Nur ein Freitext-Hinweis pro Vertrag (z. B. „siehe 1Password\" oder „Notizbuch im Schreibtisch\"). Pacto speichert keine Login-Daten — du verwaltest sie anderswo.';

  @override
  String get heirPolicyKomfortTitle => 'Komfort: in der Mail im Klartext';

  @override
  String get heirPolicyKomfortBody =>
      'Passwörter werden verschlüsselt gespeichert. Im Erbfall entschlüsselt der Pacto-Server sie und packt sie in die E-Mail an deine Erben. Vertrauensmodell: du vertraust dem Pacto-Anbieter (vergleichbar mit iCloud / Google).';

  @override
  String get heirPolicyMaximumTitle => 'Maximum: Erbe braucht PIN';

  @override
  String get heirPolicyMaximumBody =>
      'Passwörter werden mit einem Schlüssel verschlüsselt, der aus dem Erben-PIN abgeleitet wird. Der Pacto-Server kann nichts entschlüsseln. Wichtig: du musst jedem Erben den PIN vorab mitteilen (Brief, SMS, Notar). Sonst kommt er an die Daten nicht.';

  @override
  String get heirPolicySaved => 'Einstellung gespeichert.';

  @override
  String get heirPolicyWarnPinShared =>
      'Stelle sicher, dass deine Erben ihren PIN kennen — sonst können sie deine Passwörter nicht entschlüsseln.';

  @override
  String get heirPolicyPurgeTitle => 'Gespeicherte Passwörter entfernen?';

  @override
  String heirPolicyPurgeBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Verträge haben gespeicherte Passwörter.',
      one: 'Ein Vertrag hat ein gespeichertes Passwort.',
    );
    return '$_temp0 Da du \"Keine Passwörter speichern\" gewählt hast, kannst du sie jetzt aus Pacto entfernen. Benutzernamen und Hinweise bleiben erhalten.';
  }

  @override
  String get heirPolicyPurgeKeep => 'Behalten';

  @override
  String get heirPolicyPurgeConfirm => 'Passwörter löschen';

  @override
  String heirPolicyPurgeDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Passwörter entfernt.',
      one: '1 Passwort entfernt.',
    );
    return '$_temp0';
  }

  @override
  String get sectionLogin => 'Login-Daten';

  @override
  String get sectionLoginSubtitle =>
      'Optional — werden im Erbfall an die Erben weitergegeben';

  @override
  String get fieldLoginUsername => 'Benutzername / E-Mail';

  @override
  String get fieldLoginPassword => 'Passwort';

  @override
  String get fieldLoginPasswordPlaceholderExisting => '•••••• (gespeichert)';

  @override
  String get fieldLoginPasswordHintExisting =>
      'Leer lassen, um das gespeicherte Passwort zu behalten.';

  @override
  String get fieldLoginHint => 'Hinweis (falls kein Passwort gespeichert ist)';

  @override
  String get fieldLoginHintHint =>
      'z. B. \"siehe 1Password\" / \"Notizbuch im Schreibtisch\"';

  @override
  String get loginLastVerifiedNever => 'Noch nicht bestätigt';

  @override
  String loginLastVerifiedRecent(Object date) {
    return 'Bestätigt am $date';
  }

  @override
  String get loginConfirmNowButton => 'Jetzt als aktuell bestätigen';

  @override
  String get loginStaleWarning =>
      'Seit über 6 Monaten nicht bestätigt — prüfen, ob das Passwort noch stimmt.';

  @override
  String get loginPolicyHintNone =>
      'Du speicherst aktuell keine Passwörter (Einstellung: \"Keine Passwörter speichern\"). Nur das Hinweis-Feld wird in der Erben-Mail erscheinen.';

  @override
  String get loginPolicyHintKomfort =>
      'Passwörter landen im Erbfall im Klartext in der Erben-Mail (Komfort-Modus).';

  @override
  String get loginPolicyHintMaximum =>
      'Passwörter werden mit dem Erben-PIN verschlüsselt — Erbe braucht den PIN.';

  @override
  String get loginCardTitle => 'Login-Daten';

  @override
  String get loginCopied => 'In Zwischenablage kopiert';

  @override
  String get loginRevealError => 'Passwort konnte nicht entschlüsselt werden.';

  @override
  String get loginPasswordStored => 'Passwort gespeichert';

  @override
  String get heirExportPreviewButton => 'Vorschau für diesen Erben';

  @override
  String get heirExportPreviewTitle => 'So sieht die Erben-Mail aus';

  @override
  String get heirExportPinPromptTitle => 'Erben-PIN nötig';

  @override
  String get heirExportPinPromptBody =>
      'Im Maximum-Modus wird das Passwort mit dem Erben-PIN verschlüsselt. Gib den PIN ein, den du diesem Erben mitgeteilt hast.';

  @override
  String get heirExportPinPromptField => 'Erben-PIN';

  @override
  String get heirExportPinPromptButton => 'Vorschau erzeugen';

  @override
  String get heirExportCancel => 'Schließen';

  @override
  String get heirExportCopyAll => 'Alles kopieren';

  @override
  String get settingsSectionApp => 'App';

  @override
  String get settingsReplay => 'Einführung wiederholen';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacy => 'Datenschutz';

  @override
  String get settingsPrivacySubtitle => 'Daten bleiben lokal auf deinem Gerät';

  @override
  String get settingsSectionFreemium => 'Freemium';

  @override
  String get settingsFullAccess => 'Vollzugang freigeschaltet';

  @override
  String get settingsFullAccessSubtitle => 'Unbegrenzt viele Verträge';

  @override
  String get settingsUnlockFull => 'Vollzugang freischalten';

  @override
  String get settingsUnlockSubtitle => 'Mehr als 5 Verträge · einmalig ~2,99 €';

  @override
  String get settingsBuyButton => 'Kaufen';

  @override
  String get settingsRestorePurchase => 'Kauf wiederherstellen';

  @override
  String get settingsRestoreSubtitle => 'Falls du die App neu installiert hast';

  @override
  String get settingsRestoreSuccess => 'Vollzugang wiederhergestellt!';

  @override
  String get settingsRestoreNotFound => 'Kein früherer Kauf gefunden.';

  @override
  String get settingsResetPurchase => 'Kauf zurücksetzen (Debug)';

  @override
  String get settingsResetSubtitle =>
      'Nur auf Desktop — entfernt den Vollzugang lokal';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageSubtitle => 'Deutsch / English';

  @override
  String get langSystem => 'Systemsprache';

  @override
  String get langDe => 'Deutsch';

  @override
  String get langEn => 'English';

  @override
  String get cloudSyncTitle => 'Cloud-Sync';

  @override
  String get cloudEncryptionTitle => 'AES-256 verschlüsselt';

  @override
  String get cloudEncryptionDesc =>
      'Deine Daten werden vor dem Upload mit AES-256-GCM verschlüsselt. Der Schlüssel bleibt lokal auf deinem Gerät — in der Pacto-Cloud liegen nur unlesbare Daten.';

  @override
  String get syncToggle => 'Sync aktivieren';

  @override
  String get syncToggleSubtitle => 'Verschlüsseltes Backup in der Pacto-Cloud';

  @override
  String get syncLastSync => 'Letzter Sync';

  @override
  String get syncNever => 'noch nie';

  @override
  String get syncNowButton => 'Jetzt synchronisieren';

  @override
  String get syncSuccess => 'Sync erfolgreich';

  @override
  String get syncReadyNote =>
      'Cloud-Backup ist startklar konfiguriert — keine Einrichtung nötig. Du musst Sync nur aktivieren.';

  @override
  String get vaultTitle => 'Lebenszeichen-Tresor';

  @override
  String get vaultInfoTitle => 'Für den Fall der Fälle';

  @override
  String get vaultInfoDesc =>
      'Wenn du eine Weile nicht mehr aktiv warst, erhalten deine hinterlegten Erben automatisch Zugang. Jede App-Nutzung und der Button unten bestätigen, dass alles in Ordnung ist.';

  @override
  String get vaultToggle => 'Tresor aktivieren';

  @override
  String get vaultToggleSubtitle =>
      'Benötigt aktivierten Cloud-Sync für die Weitergabe';

  @override
  String get vaultLastConfirmed => 'Letzte Bestätigung';

  @override
  String get vaultExpiry => 'Frist läuft ab';

  @override
  String get vaultNever => 'noch nie';

  @override
  String get vaultConfirmButton => 'Mir geht es gut — Frist zurücksetzen';

  @override
  String get vaultConfirmSnackbar => 'Lebenszeichen aktualisiert';

  @override
  String get vaultIntervalLabel => 'Intervall';

  @override
  String vaultIntervalDays(int days) {
    return '$days Tage';
  }

  @override
  String get vaultServerTitle => 'Server-seitiger Trigger';

  @override
  String get vaultServerDesc =>
      'Die automatische Weiterleitung an die Erben übernimmt eine Supabase-Edge-Function (pg_cron + PDF-Generierung + E-Mail-Versand). Diese Komponente ist außerhalb der App vorbereitet und nicht Teil der lokalen Installation.';

  @override
  String get vaultOwnerEmailLabel => 'Deine E-Mail für Vorwarnungen';

  @override
  String get vaultOwnerEmailHint =>
      'An diese Adresse senden wir kurz vor Auslösung eine Warnmail.';

  @override
  String get vaultOwnerEmailRequired =>
      'E-Mail-Adresse fehlt — ohne sie kann der Tresor nicht warnen.';

  @override
  String get vaultSyncNowButton => 'Erbendaten jetzt hochladen';

  @override
  String vaultSyncSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Erben-Briefe im Tresor abgelegt.',
      one: '1 Erben-Brief im Tresor abgelegt.',
    );
    return '$_temp0';
  }

  @override
  String get vaultLastSyncLabel => 'Zuletzt synchronisiert';

  @override
  String get vaultLastSyncNever => 'noch nicht';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get onboardingStart => 'Loslegen';

  @override
  String get onboardingNameTitle => 'Wie heißt du?';

  @override
  String get onboardingNameBody => 'So kann Pacto dich persönlich begrüßen.';

  @override
  String get onboardingNameHint => 'Dein Vorname';

  @override
  String get onboardingNameSkip => 'Lieber anonym bleiben';

  @override
  String get onboarding1Title => 'Weißt du wirklich was du jeden Monat zahlst?';

  @override
  String get onboarding1Body =>
      'Pacto sammelt alle deine Abos und Verträge an einem Ort — mit Kosten, Kündigungsfristen und Anleitung zur Beendigung.';

  @override
  String get onboarding2Title => 'Foto rein — Daten raus';

  @override
  String get onboarding2Body =>
      'Mach ein Foto vom Vertrag oder teile ein PDF an Pacto. Die KI füllt das Formular automatisch aus.';

  @override
  String get onboarding3Title => 'Für den Fall der Fälle';

  @override
  String get onboarding3Body =>
      'Hinterlege Erben mit PIN-Zugang. So weiß im Ernstfall sofort jemand Bescheid — ruhig, sicher, nur dann zugänglich, wenn nötig.';

  @override
  String get webSearchUnsupportedPlatform =>
      'Die Web-Suche ist nur auf Mobilgeräten (Android, iOS) und macOS verfügbar.\n\nAuf dem Desktop kannst du Verträge manuell einpflegen.';
}
