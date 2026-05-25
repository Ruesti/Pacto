// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pacto';

  @override
  String get saveButton => 'Save';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteButton => 'Delete';

  @override
  String get retryButton => 'Try again';

  @override
  String errorMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get daysExpired => 'expired';

  @override
  String get daysToday => 'today';

  @override
  String get daysTomorrow => 'tomorrow';

  @override
  String daysIn(int days) {
    return 'in $days days';
  }

  @override
  String get catStreaming => 'Streaming';

  @override
  String get catVersicherung => 'Insurance';

  @override
  String get catHandy => 'Mobile';

  @override
  String get catInternet => 'Internet';

  @override
  String get catSoftware => 'Software';

  @override
  String get catFitness => 'Fitness';

  @override
  String get catZeitung => 'News / Media';

  @override
  String get catSonstiges => 'Other';

  @override
  String get billingMonthly => 'Monthly';

  @override
  String get billingQuarterly => 'Quarterly';

  @override
  String get billingYearly => 'Yearly';

  @override
  String get billingWeekly => 'Weekly';

  @override
  String get cancBrief => 'Letter';

  @override
  String get cancOnline => 'Online';

  @override
  String get cancTelefon => 'Phone';

  @override
  String get cancEmail => 'Email';

  @override
  String get cancAutomatisch => 'Automatic (no action needed)';

  @override
  String get accessVollzugang => 'Full access (all fields)';

  @override
  String get accessNurListe => 'List only (name, cost, cancellation)';

  @override
  String get searchHint => 'Search by name or provider…';

  @override
  String get addContractFab => 'Contract';

  @override
  String get filterAll => 'All';

  @override
  String get noContractsTitle => 'No contracts yet';

  @override
  String get noContractsDefault =>
      'Add your first contract.\nDo you really know what you pay each month?';

  @override
  String noContractsSearch(String query) {
    return 'No contract found for \"$query\"';
  }

  @override
  String get noContractsCategory => 'No contract in this category';

  @override
  String get sortByTitle => 'Sort by';

  @override
  String get sortCost => 'Cost (highest first)';

  @override
  String get sortName => 'Name (A–Z)';

  @override
  String get sortCategory => 'Category';

  @override
  String get sortRenewal => 'Next renewal';

  @override
  String dashboardGreeting(String name) {
    return 'Hello, $name!';
  }

  @override
  String get dashboardGreetingAnon => 'My Contracts';

  @override
  String get monthlyCosts => 'Monthly expenses';

  @override
  String perYear(String amount) {
    return '$amount per year';
  }

  @override
  String contractsLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'contracts',
      one: 'contract',
    );
    return '$_temp0';
  }

  @override
  String get addContractTitle => 'Add contract';

  @override
  String get editContractTitle => 'Edit contract';

  @override
  String get updateButton => 'Update';

  @override
  String get sectionBasic => 'Basic info';

  @override
  String get sectionCost => 'Cost';

  @override
  String get sectionCancellation => 'Cancellation';

  @override
  String get sectionContact => 'Contact';

  @override
  String get sectionDuration => 'Duration';

  @override
  String get sectionNotes => 'Notes';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldProvider => 'Provider';

  @override
  String get fieldCategory => 'Category';

  @override
  String get fieldAmount => 'Amount (€)';

  @override
  String get fieldCycle => 'Cycle';

  @override
  String get fieldCancellationMethod => 'Method';

  @override
  String get fieldNoticePeriod => 'Notice period';

  @override
  String get fieldNoticePeriodHint => 'e.g. \"3 months to quarter end\"';

  @override
  String get fieldCancellationInstructions => 'Cancellation instructions';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldWebsite => 'Website';

  @override
  String get fieldContractStart => 'Contract start';

  @override
  String get fieldNextRenewal => 'Next renewal';

  @override
  String get fieldNotesHint => 'Special terms, early cancellation rights…';

  @override
  String get validationNameRequired => 'Name is required';

  @override
  String get validationProviderRequired => 'Provider is required';

  @override
  String get validationEmailRequired => 'Email is required';

  @override
  String get validationPinTooShort => 'PIN must have at least 6 digits';

  @override
  String get pickDate => 'Pick date';

  @override
  String get confidenceHigh =>
      'AI extraction successful. Please review the imported data.';

  @override
  String get confidenceMedium =>
      'Some fields are uncertain. Please review carefully.';

  @override
  String get confidenceLow =>
      'Only a few fields recognized. Please review all data or scan again.';

  @override
  String get entrySheetTitle => 'Add contract';

  @override
  String get entryLibrary => 'Choose from library';

  @override
  String get entryLibrarySubtitle => 'Netflix, Spotify, Telekom & more';

  @override
  String get entryManual => 'Enter manually';

  @override
  String get entryManualSubtitle => 'Fill in all fields yourself';

  @override
  String get entryScan => 'Scan document (AI)';

  @override
  String get entryScanSubtitle => 'Photo or PDF → auto-fill';

  @override
  String get entryWebSearch => 'Search online contract (AI)';

  @override
  String get entryWebSearchSubtitle => 'Provider website → auto-fill';

  @override
  String get scanTitle => 'Scan document';

  @override
  String get scanChooseSource => 'Choose a source';

  @override
  String get scanHint => 'AI automatically extracts contract details.';

  @override
  String get scanFromGallery => 'Photo from gallery';

  @override
  String get scanFromFile => 'Select file / PDF';

  @override
  String get scanLoading => 'AI is analyzing document…';

  @override
  String get shareImportTitleUrl => 'Analyze website';

  @override
  String get shareImportTitleFile => 'Shared document';

  @override
  String get shareImportLoadingUrl => 'AI is analyzing the website…';

  @override
  String get shareImportLoadingFile => 'AI is analyzing the shared document…';

  @override
  String get createManually => 'Create manually';

  @override
  String get webSearchHint => 'Search or enter URL';

  @override
  String get webSearchImportButton => 'Import';

  @override
  String get webSearchImportTooltip => 'Analyze this page with AI';

  @override
  String get urlProcessingTitle => 'Analyze page';

  @override
  String get urlProcessingLoading => 'AI is analyzing the website…';

  @override
  String get contractNotFound => 'Contract not found';

  @override
  String get contactSectionTitle => 'Contact';

  @override
  String get notesSectionTitle => 'Notes';

  @override
  String get contractStartLabel => 'Start';

  @override
  String get renewalLabel => 'Renewal';

  @override
  String get deleteContractTitle => 'Delete contract?';

  @override
  String deleteContractContent(String name) {
    return 'Really delete \"$name\" permanently?';
  }

  @override
  String get cancellationCardTitle => 'Cancellation';

  @override
  String get cancellationMethodLabel => 'Method';

  @override
  String get cancellationPeriodLabel => 'Notice period';

  @override
  String get cancellationRenewalLabel => 'Next renewal';

  @override
  String get cancellationInstructionsLabel => 'Instructions:';

  @override
  String get heirsTitle => 'Heirs & Sharing';

  @override
  String get heirsInfoText =>
      'Heirs get access to your contracts. Just in case.';

  @override
  String get heirsEmptyTitle => 'No heirs added yet';

  @override
  String get heirsEmptySubtitle =>
      'Define who gets access to\nyour contracts in case of emergency.';

  @override
  String get heirAddFab => 'Add heir';

  @override
  String get exportPdfTooltip => 'Export PDF';

  @override
  String exportedPath(String path) {
    return 'Exported: $path';
  }

  @override
  String get noContractsToExport => 'No contracts to export';

  @override
  String get deleteHeirTitle => 'Delete heir?';

  @override
  String deleteHeirContent(String name) {
    return 'Really remove $name?';
  }

  @override
  String get heirEditTitle => 'Edit heir';

  @override
  String get heirAddTitle => 'Add heir';

  @override
  String get fieldPin => 'Set PIN';

  @override
  String get fieldPinEdit => 'Set new PIN (optional)';

  @override
  String get fieldPinHelper => 'Min. 6 digits';

  @override
  String get fieldAccessLevel => 'Access level';

  @override
  String get accessLevelsTitle => 'Access levels explained:';

  @override
  String get premiumDialogTitle => 'Unlock full access';

  @override
  String get premiumDialogContent =>
      'You\'ve reached the free limit of 5 contracts.\n\nWith full access you can manage unlimited contracts — one-time purchase, no subscription.\n\nFinal release: ~€2.99';

  @override
  String get premiumLater => 'Later';

  @override
  String get premiumUnlock => 'Buy now';

  @override
  String get premiumPurchaseFailed => 'Purchase failed. Please try again.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionData => 'Data & Sync';

  @override
  String get settingsCloudSync => 'Cloud Sync (Supabase)';

  @override
  String get settingsCloudSyncSubtitle => 'Encrypted backup, AES-256';

  @override
  String get settingsVault => 'Vitality Vault';

  @override
  String get settingsVaultSubtitle => 'Automatic handover to heirs';

  @override
  String get settingsSectionApp => 'App';

  @override
  String get settingsReplay => 'Replay introduction';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsPrivacySubtitle => 'Data stays local on your device';

  @override
  String get settingsSectionFreemium => 'Freemium';

  @override
  String get settingsFullAccess => 'Full access unlocked';

  @override
  String get settingsFullAccessSubtitle => 'Unlimited contracts';

  @override
  String get settingsUnlockFull => 'Unlock full access';

  @override
  String get settingsUnlockSubtitle =>
      'More than 5 contracts · one-time ~€2.99';

  @override
  String get settingsBuyButton => 'Buy';

  @override
  String get settingsRestorePurchase => 'Restore purchase';

  @override
  String get settingsRestoreSubtitle => 'If you reinstalled the app';

  @override
  String get settingsRestoreSuccess => 'Full access restored!';

  @override
  String get settingsRestoreNotFound => 'No previous purchase found.';

  @override
  String get settingsResetPurchase => 'Reset purchase (Debug)';

  @override
  String get settingsResetSubtitle =>
      'Desktop only — removes full access locally';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Deutsch / English';

  @override
  String get langSystem => 'System language';

  @override
  String get langDe => 'Deutsch';

  @override
  String get langEn => 'English';

  @override
  String get cloudSyncTitle => 'Cloud Sync';

  @override
  String get cloudEncryptionTitle => 'AES-256 encrypted';

  @override
  String get cloudEncryptionDesc =>
      'Your data is encrypted with AES-256-GCM before upload. The key stays local on your device — the Pacto cloud only stores unreadable data.';

  @override
  String get syncToggle => 'Enable sync';

  @override
  String get syncToggleSubtitle => 'Encrypted backup in the Pacto cloud';

  @override
  String get syncLastSync => 'Last sync';

  @override
  String get syncNever => 'never';

  @override
  String get syncNowButton => 'Sync now';

  @override
  String get syncSuccess => 'Sync successful';

  @override
  String get syncReadyNote =>
      'Cloud backup is ready to go — no setup needed. You just need to enable sync.';

  @override
  String get vaultTitle => 'Vitality Vault';

  @override
  String get vaultInfoTitle => 'Just in case';

  @override
  String get vaultInfoDesc =>
      'If you have been inactive for a while, your registered heirs automatically get access. Every app use and the button below confirm that everything is fine.';

  @override
  String get vaultToggle => 'Activate vault';

  @override
  String get vaultToggleSubtitle => 'Requires active cloud sync for handover';

  @override
  String get vaultLastConfirmed => 'Last confirmation';

  @override
  String get vaultExpiry => 'Deadline expires';

  @override
  String get vaultNever => 'never';

  @override
  String get vaultConfirmButton => 'I\'m fine — reset deadline';

  @override
  String get vaultConfirmSnackbar => 'Vital sign updated';

  @override
  String get vaultIntervalLabel => 'Interval';

  @override
  String vaultIntervalDays(int days) {
    return '$days days';
  }

  @override
  String get vaultServerTitle => 'Server-side trigger';

  @override
  String get vaultServerDesc =>
      'The automatic handover to heirs is handled by a Supabase Edge Function (pg_cron + PDF generation + email sending). This component is prepared outside the app and is not part of the local installation.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get onboardingNameTitle => 'What\'s your name?';

  @override
  String get onboardingNameBody => 'Pacto will greet you personally.';

  @override
  String get onboardingNameHint => 'Your first name';

  @override
  String get onboardingNameSkip => 'Stay anonymous';

  @override
  String get onboarding1Title => 'Do you really know what you pay each month?';

  @override
  String get onboarding1Body =>
      'Pacto collects all your subscriptions and contracts in one place — with costs, notice periods, and cancellation instructions.';

  @override
  String get onboarding2Title => 'Photo in — data out';

  @override
  String get onboarding2Body =>
      'Take a photo of the contract or share a PDF to Pacto. The AI fills in the form automatically.';

  @override
  String get onboarding3Title => 'Just in case';

  @override
  String get onboarding3Body =>
      'Register heirs with PIN access. So someone always knows what to do — calm, secure, only accessible when needed.';

  @override
  String get webSearchUnsupportedPlatform =>
      'Web search is only available on mobile devices (Android, iOS) and macOS.\n\nOn desktop, you can add contracts manually.';
}
