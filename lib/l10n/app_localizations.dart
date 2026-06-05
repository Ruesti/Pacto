import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'Pacto'**
  String get appTitle;

  /// No description provided for @saveButton.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get saveButton;

  /// No description provided for @cancelButton.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancelButton;

  /// No description provided for @deleteButton.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get deleteButton;

  /// No description provided for @retryButton.
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get retryButton;

  /// No description provided for @errorMessage.
  ///
  /// In de, this message translates to:
  /// **'Fehler: {error}'**
  String errorMessage(String error);

  /// No description provided for @daysExpired.
  ///
  /// In de, this message translates to:
  /// **'abgelaufen'**
  String get daysExpired;

  /// No description provided for @daysToday.
  ///
  /// In de, this message translates to:
  /// **'heute'**
  String get daysToday;

  /// No description provided for @daysTomorrow.
  ///
  /// In de, this message translates to:
  /// **'morgen'**
  String get daysTomorrow;

  /// No description provided for @daysIn.
  ///
  /// In de, this message translates to:
  /// **'in {days} Tagen'**
  String daysIn(int days);

  /// No description provided for @catStreaming.
  ///
  /// In de, this message translates to:
  /// **'Streaming'**
  String get catStreaming;

  /// No description provided for @catVersicherung.
  ///
  /// In de, this message translates to:
  /// **'Versicherung'**
  String get catVersicherung;

  /// No description provided for @catHandy.
  ///
  /// In de, this message translates to:
  /// **'Handy'**
  String get catHandy;

  /// No description provided for @catInternet.
  ///
  /// In de, this message translates to:
  /// **'Internet'**
  String get catInternet;

  /// No description provided for @catSoftware.
  ///
  /// In de, this message translates to:
  /// **'Software'**
  String get catSoftware;

  /// No description provided for @catFitness.
  ///
  /// In de, this message translates to:
  /// **'Fitness'**
  String get catFitness;

  /// No description provided for @catZeitung.
  ///
  /// In de, this message translates to:
  /// **'Zeitung / Medien'**
  String get catZeitung;

  /// No description provided for @catSonstiges.
  ///
  /// In de, this message translates to:
  /// **'Sonstiges'**
  String get catSonstiges;

  /// No description provided for @accessCatRouter.
  ///
  /// In de, this message translates to:
  /// **'Router / WLAN'**
  String get accessCatRouter;

  /// No description provided for @accessCatSmarthome.
  ///
  /// In de, this message translates to:
  /// **'Smart Home'**
  String get accessCatSmarthome;

  /// No description provided for @accessCatEmail.
  ///
  /// In de, this message translates to:
  /// **'E-Mail / Konto'**
  String get accessCatEmail;

  /// No description provided for @accessCatBanking.
  ///
  /// In de, this message translates to:
  /// **'Banking'**
  String get accessCatBanking;

  /// No description provided for @accessCatServer.
  ///
  /// In de, this message translates to:
  /// **'Server / NAS'**
  String get accessCatServer;

  /// No description provided for @accessCatPartnerAccount.
  ///
  /// In de, this message translates to:
  /// **'Partner-Zugang'**
  String get accessCatPartnerAccount;

  /// No description provided for @accessCatGeraet.
  ///
  /// In de, this message translates to:
  /// **'Gerät'**
  String get accessCatGeraet;

  /// No description provided for @accessCatSonstiges.
  ///
  /// In de, this message translates to:
  /// **'Sonstiges'**
  String get accessCatSonstiges;

  /// No description provided for @entryAccess.
  ///
  /// In de, this message translates to:
  /// **'Zugang anlegen'**
  String get entryAccess;

  /// No description provided for @entryAccessSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Login ohne Vertrag (Router, Server, Partner …)'**
  String get entryAccessSubtitle;

  /// No description provided for @addAccessTitle.
  ///
  /// In de, this message translates to:
  /// **'Zugang hinzufügen'**
  String get addAccessTitle;

  /// No description provided for @editAccessTitle.
  ///
  /// In de, this message translates to:
  /// **'Zugang bearbeiten'**
  String get editAccessTitle;

  /// No description provided for @accessesTitle.
  ///
  /// In de, this message translates to:
  /// **'Zugänge'**
  String get accessesTitle;

  /// No description provided for @segmentContracts.
  ///
  /// In de, this message translates to:
  /// **'Verträge'**
  String get segmentContracts;

  /// No description provided for @segmentAccesses.
  ///
  /// In de, this message translates to:
  /// **'Zugänge'**
  String get segmentAccesses;

  /// No description provided for @fieldAccessCategory.
  ///
  /// In de, this message translates to:
  /// **'Art des Zugangs'**
  String get fieldAccessCategory;

  /// No description provided for @noAccessesTitle.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Zugänge'**
  String get noAccessesTitle;

  /// No description provided for @noAccessesDefault.
  ///
  /// In de, this message translates to:
  /// **'Lege Zugänge an, die deine Erben brauchen:\nRouter, Server, E-Mail-Konto.'**
  String get noAccessesDefault;

  /// No description provided for @billingMonthly.
  ///
  /// In de, this message translates to:
  /// **'Monatlich'**
  String get billingMonthly;

  /// No description provided for @billingQuarterly.
  ///
  /// In de, this message translates to:
  /// **'Vierteljährlich'**
  String get billingQuarterly;

  /// No description provided for @billingYearly.
  ///
  /// In de, this message translates to:
  /// **'Jährlich'**
  String get billingYearly;

  /// No description provided for @billingWeekly.
  ///
  /// In de, this message translates to:
  /// **'Wöchentlich'**
  String get billingWeekly;

  /// No description provided for @cancBrief.
  ///
  /// In de, this message translates to:
  /// **'Brief'**
  String get cancBrief;

  /// No description provided for @cancOnline.
  ///
  /// In de, this message translates to:
  /// **'Online'**
  String get cancOnline;

  /// No description provided for @cancTelefon.
  ///
  /// In de, this message translates to:
  /// **'Telefon'**
  String get cancTelefon;

  /// No description provided for @cancEmail.
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get cancEmail;

  /// No description provided for @cancAutomatisch.
  ///
  /// In de, this message translates to:
  /// **'Automatisch (kein Handlungsbedarf)'**
  String get cancAutomatisch;

  /// No description provided for @accessVollzugang.
  ///
  /// In de, this message translates to:
  /// **'Vollzugang (alle Felder)'**
  String get accessVollzugang;

  /// No description provided for @accessNurListe.
  ///
  /// In de, this message translates to:
  /// **'Nur Liste (Name, Kosten, Kündigung)'**
  String get accessNurListe;

  /// No description provided for @searchHint.
  ///
  /// In de, this message translates to:
  /// **'Suche nach Name oder Anbieter…'**
  String get searchHint;

  /// No description provided for @addContractFab.
  ///
  /// In de, this message translates to:
  /// **'Vertrag'**
  String get addContractFab;

  /// No description provided for @filterAll.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get filterAll;

  /// No description provided for @noContractsTitle.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Verträge'**
  String get noContractsTitle;

  /// No description provided for @noContractsDefault.
  ///
  /// In de, this message translates to:
  /// **'Füge deinen ersten Vertrag hinzu.\nWeißt du wirklich was du zahlst?'**
  String get noContractsDefault;

  /// No description provided for @noContractsSearch.
  ///
  /// In de, this message translates to:
  /// **'Kein Vertrag gefunden für \"{query}\"'**
  String noContractsSearch(String query);

  /// No description provided for @noContractsCategory.
  ///
  /// In de, this message translates to:
  /// **'Kein Vertrag in dieser Kategorie'**
  String get noContractsCategory;

  /// No description provided for @sortByTitle.
  ///
  /// In de, this message translates to:
  /// **'Sortieren nach'**
  String get sortByTitle;

  /// No description provided for @sortCost.
  ///
  /// In de, this message translates to:
  /// **'Kosten (höchste zuerst)'**
  String get sortCost;

  /// No description provided for @sortName.
  ///
  /// In de, this message translates to:
  /// **'Name (A–Z)'**
  String get sortName;

  /// No description provided for @sortCategory.
  ///
  /// In de, this message translates to:
  /// **'Kategorie'**
  String get sortCategory;

  /// No description provided for @sortRenewal.
  ///
  /// In de, this message translates to:
  /// **'Nächste Verlängerung'**
  String get sortRenewal;

  /// No description provided for @dashboardGreeting.
  ///
  /// In de, this message translates to:
  /// **'Hallo {name} 👋'**
  String dashboardGreeting(String name);

  /// No description provided for @dashboardGreetingAnon.
  ///
  /// In de, this message translates to:
  /// **'Hallo 👋'**
  String get dashboardGreetingAnon;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Deine Verträge. Deine Übersicht. Für deine Liebsten.'**
  String get dashboardSubtitle;

  /// No description provided for @sectionOverview.
  ///
  /// In de, this message translates to:
  /// **'Übersicht'**
  String get sectionOverview;

  /// No description provided for @sectionYourContracts.
  ///
  /// In de, this message translates to:
  /// **'Deine Verträge'**
  String get sectionYourContracts;

  /// No description provided for @sectionShowAll.
  ///
  /// In de, this message translates to:
  /// **'Alle anzeigen'**
  String get sectionShowAll;

  /// No description provided for @statContracts.
  ///
  /// In de, this message translates to:
  /// **'Verträge'**
  String get statContracts;

  /// No description provided for @statContractsHint.
  ///
  /// In de, this message translates to:
  /// **'aktiv'**
  String get statContractsHint;

  /// No description provided for @statCancellations.
  ///
  /// In de, this message translates to:
  /// **'Kündigungen'**
  String get statCancellations;

  /// No description provided for @statCancellationsHint.
  ///
  /// In de, this message translates to:
  /// **'nächste 30 Tage'**
  String get statCancellationsHint;

  /// No description provided for @statSubscriptions.
  ///
  /// In de, this message translates to:
  /// **'Abos'**
  String get statSubscriptions;

  /// No description provided for @statSubscriptionsHint.
  ///
  /// In de, this message translates to:
  /// **'aktiv'**
  String get statSubscriptionsHint;

  /// No description provided for @statHeirs.
  ///
  /// In de, this message translates to:
  /// **'Erben'**
  String get statHeirs;

  /// No description provided for @statHeirsHint.
  ///
  /// In de, this message translates to:
  /// **'hinterlegt'**
  String get statHeirsHint;

  /// No description provided for @emergencyLabel.
  ///
  /// In de, this message translates to:
  /// **'Für den Notfall'**
  String get emergencyLabel;

  /// No description provided for @emergencyHeadlineNotified.
  ///
  /// In de, this message translates to:
  /// **'Deine Erben sind informiert'**
  String get emergencyHeadlineNotified;

  /// No description provided for @emergencyBodyNotified.
  ///
  /// In de, this message translates to:
  /// **'Im Ernstfall werden deine Erben benachrichtigt und erhalten Zugriff auf deine Vertragsübersicht.'**
  String get emergencyBodyNotified;

  /// No description provided for @emergencyHeadlineEmpty.
  ///
  /// In de, this message translates to:
  /// **'Noch niemand hinterlegt'**
  String get emergencyHeadlineEmpty;

  /// No description provided for @emergencyBodyEmpty.
  ///
  /// In de, this message translates to:
  /// **'Lege fest, wer im Fall der Fälle Zugang zu deinen Verträgen erhält.'**
  String get emergencyBodyEmpty;

  /// No description provided for @emergencyAction.
  ///
  /// In de, this message translates to:
  /// **'Erben verwalten'**
  String get emergencyAction;

  /// No description provided for @navOverview.
  ///
  /// In de, this message translates to:
  /// **'Übersicht'**
  String get navOverview;

  /// No description provided for @navContracts.
  ///
  /// In de, this message translates to:
  /// **'Verträge'**
  String get navContracts;

  /// No description provided for @navAdd.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get navAdd;

  /// No description provided for @navHeirs.
  ///
  /// In de, this message translates to:
  /// **'Erben'**
  String get navHeirs;

  /// No description provided for @navMore.
  ///
  /// In de, this message translates to:
  /// **'Mehr'**
  String get navMore;

  /// No description provided for @nextPayment.
  ///
  /// In de, this message translates to:
  /// **'Nächste Zahlung: {date}'**
  String nextPayment(String date);

  /// No description provided for @perMonthSuffix.
  ///
  /// In de, this message translates to:
  /// **'/ Monat'**
  String get perMonthSuffix;

  /// No description provided for @monthlyCosts.
  ///
  /// In de, this message translates to:
  /// **'Monatliche Ausgaben'**
  String get monthlyCosts;

  /// No description provided for @perYear.
  ///
  /// In de, this message translates to:
  /// **'{amount} pro Jahr'**
  String perYear(String amount);

  /// No description provided for @contractsLabel.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, one{Vertrag} other{Verträge}}'**
  String contractsLabel(num count);

  /// No description provided for @addContractTitle.
  ///
  /// In de, this message translates to:
  /// **'Vertrag hinzufügen'**
  String get addContractTitle;

  /// No description provided for @editContractTitle.
  ///
  /// In de, this message translates to:
  /// **'Vertrag bearbeiten'**
  String get editContractTitle;

  /// No description provided for @updateButton.
  ///
  /// In de, this message translates to:
  /// **'Aktualisieren'**
  String get updateButton;

  /// No description provided for @sectionBasic.
  ///
  /// In de, this message translates to:
  /// **'Basisdaten'**
  String get sectionBasic;

  /// No description provided for @sectionCost.
  ///
  /// In de, this message translates to:
  /// **'Kosten'**
  String get sectionCost;

  /// No description provided for @sectionCancellation.
  ///
  /// In de, this message translates to:
  /// **'Kündigung'**
  String get sectionCancellation;

  /// No description provided for @sectionContact.
  ///
  /// In de, this message translates to:
  /// **'Kontakt'**
  String get sectionContact;

  /// No description provided for @sectionDuration.
  ///
  /// In de, this message translates to:
  /// **'Laufzeit'**
  String get sectionDuration;

  /// No description provided for @sectionNotes.
  ///
  /// In de, this message translates to:
  /// **'Notizen'**
  String get sectionNotes;

  /// No description provided for @fieldName.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldProvider.
  ///
  /// In de, this message translates to:
  /// **'Anbieter'**
  String get fieldProvider;

  /// No description provided for @fieldCategory.
  ///
  /// In de, this message translates to:
  /// **'Kategorie'**
  String get fieldCategory;

  /// No description provided for @fieldAmount.
  ///
  /// In de, this message translates to:
  /// **'Betrag (€)'**
  String get fieldAmount;

  /// No description provided for @fieldCycle.
  ///
  /// In de, this message translates to:
  /// **'Zyklus'**
  String get fieldCycle;

  /// No description provided for @fieldCancellationMethod.
  ///
  /// In de, this message translates to:
  /// **'Methode'**
  String get fieldCancellationMethod;

  /// No description provided for @fieldNoticePeriod.
  ///
  /// In de, this message translates to:
  /// **'Kündigungsfrist'**
  String get fieldNoticePeriod;

  /// No description provided for @fieldNoticePeriodHint.
  ///
  /// In de, this message translates to:
  /// **'z. B. \"3 Monate zum Quartalsende\"'**
  String get fieldNoticePeriodHint;

  /// No description provided for @fieldCancellationInstructions.
  ///
  /// In de, this message translates to:
  /// **'Kündigungsanleitung'**
  String get fieldCancellationInstructions;

  /// No description provided for @fieldPhone.
  ///
  /// In de, this message translates to:
  /// **'Telefon'**
  String get fieldPhone;

  /// No description provided for @fieldEmail.
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get fieldEmail;

  /// No description provided for @fieldWebsite.
  ///
  /// In de, this message translates to:
  /// **'Website'**
  String get fieldWebsite;

  /// No description provided for @fieldContractStart.
  ///
  /// In de, this message translates to:
  /// **'Vertragsbeginn'**
  String get fieldContractStart;

  /// No description provided for @fieldNextRenewal.
  ///
  /// In de, this message translates to:
  /// **'Nächste Verlängerung'**
  String get fieldNextRenewal;

  /// No description provided for @fieldNotesHint.
  ///
  /// In de, this message translates to:
  /// **'Besonderheiten, Sonderkündigungsrecht…'**
  String get fieldNotesHint;

  /// No description provided for @validationNameRequired.
  ///
  /// In de, this message translates to:
  /// **'Name ist erforderlich'**
  String get validationNameRequired;

  /// No description provided for @validationProviderRequired.
  ///
  /// In de, this message translates to:
  /// **'Anbieter ist erforderlich'**
  String get validationProviderRequired;

  /// No description provided for @validationEmailRequired.
  ///
  /// In de, this message translates to:
  /// **'E-Mail ist erforderlich'**
  String get validationEmailRequired;

  /// No description provided for @validationPinTooShort.
  ///
  /// In de, this message translates to:
  /// **'PIN muss mind. 6 Ziffern haben'**
  String get validationPinTooShort;

  /// No description provided for @pickDate.
  ///
  /// In de, this message translates to:
  /// **'Datum wählen'**
  String get pickDate;

  /// No description provided for @confidenceHigh.
  ///
  /// In de, this message translates to:
  /// **'KI-Extraktion erfolgreich. Bitte prüfe die übernommenen Angaben.'**
  String get confidenceHigh;

  /// No description provided for @confidenceMedium.
  ///
  /// In de, this message translates to:
  /// **'Einige Felder sind unsicher. Bitte sorgfältig prüfen.'**
  String get confidenceMedium;

  /// No description provided for @confidenceLow.
  ///
  /// In de, this message translates to:
  /// **'Nur wenige Felder erkannt. Bitte alle Angaben prüfen oder erneut scannen.'**
  String get confidenceLow;

  /// No description provided for @entrySheetTitle.
  ///
  /// In de, this message translates to:
  /// **'Vertrag hinzufügen'**
  String get entrySheetTitle;

  /// No description provided for @entryLibrary.
  ///
  /// In de, this message translates to:
  /// **'Aus Bibliothek wählen'**
  String get entryLibrary;

  /// No description provided for @entryLibrarySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Netflix, Spotify, Telekom & mehr'**
  String get entryLibrarySubtitle;

  /// No description provided for @entryManual.
  ///
  /// In de, this message translates to:
  /// **'Manuell eingeben'**
  String get entryManual;

  /// No description provided for @entryManualSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Alle Felder selbst ausfüllen'**
  String get entryManualSubtitle;

  /// No description provided for @entryScan.
  ///
  /// In de, this message translates to:
  /// **'Dokument scannen (KI)'**
  String get entryScan;

  /// No description provided for @entryScanSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Foto oder PDF → automatisch ausfüllen'**
  String get entryScanSubtitle;

  /// No description provided for @entryWebSearch.
  ///
  /// In de, this message translates to:
  /// **'Online-Vertrag suchen (KI)'**
  String get entryWebSearch;

  /// No description provided for @entryWebSearchSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Webseite des Anbieters → automatisch ausfüllen'**
  String get entryWebSearchSubtitle;

  /// No description provided for @scanTitle.
  ///
  /// In de, this message translates to:
  /// **'Dokument scannen'**
  String get scanTitle;

  /// No description provided for @scanChooseSource.
  ///
  /// In de, this message translates to:
  /// **'Wähle eine Quelle'**
  String get scanChooseSource;

  /// No description provided for @scanHint.
  ///
  /// In de, this message translates to:
  /// **'Die KI extrahiert automatisch Vertragsdetails.'**
  String get scanHint;

  /// No description provided for @scanFromGallery.
  ///
  /// In de, this message translates to:
  /// **'Foto aus Galerie'**
  String get scanFromGallery;

  /// No description provided for @scanFromFile.
  ///
  /// In de, this message translates to:
  /// **'Datei / PDF auswählen'**
  String get scanFromFile;

  /// No description provided for @scanLoading.
  ///
  /// In de, this message translates to:
  /// **'KI analysiert Dokument…'**
  String get scanLoading;

  /// No description provided for @shareImportTitleUrl.
  ///
  /// In de, this message translates to:
  /// **'Webseite analysieren'**
  String get shareImportTitleUrl;

  /// No description provided for @shareImportTitleFile.
  ///
  /// In de, this message translates to:
  /// **'Geteiltes Dokument'**
  String get shareImportTitleFile;

  /// No description provided for @shareImportLoadingUrl.
  ///
  /// In de, this message translates to:
  /// **'KI analysiert die Webseite…'**
  String get shareImportLoadingUrl;

  /// No description provided for @shareImportLoadingFile.
  ///
  /// In de, this message translates to:
  /// **'KI analysiert das geteilte Dokument…'**
  String get shareImportLoadingFile;

  /// No description provided for @createManually.
  ///
  /// In de, this message translates to:
  /// **'Manuell anlegen'**
  String get createManually;

  /// No description provided for @webSearchHint.
  ///
  /// In de, this message translates to:
  /// **'Suche oder URL eingeben'**
  String get webSearchHint;

  /// No description provided for @webSearchImportButton.
  ///
  /// In de, this message translates to:
  /// **'Einpflegen'**
  String get webSearchImportButton;

  /// No description provided for @webSearchImportTooltip.
  ///
  /// In de, this message translates to:
  /// **'Diese Seite per KI auswerten'**
  String get webSearchImportTooltip;

  /// No description provided for @urlProcessingTitle.
  ///
  /// In de, this message translates to:
  /// **'Seite analysieren'**
  String get urlProcessingTitle;

  /// No description provided for @urlProcessingLoading.
  ///
  /// In de, this message translates to:
  /// **'KI analysiert die Webseite…'**
  String get urlProcessingLoading;

  /// No description provided for @contractNotFound.
  ///
  /// In de, this message translates to:
  /// **'Vertrag nicht gefunden'**
  String get contractNotFound;

  /// No description provided for @contactSectionTitle.
  ///
  /// In de, this message translates to:
  /// **'Kontakt'**
  String get contactSectionTitle;

  /// No description provided for @notesSectionTitle.
  ///
  /// In de, this message translates to:
  /// **'Notizen'**
  String get notesSectionTitle;

  /// No description provided for @contractStartLabel.
  ///
  /// In de, this message translates to:
  /// **'Beginn'**
  String get contractStartLabel;

  /// No description provided for @renewalLabel.
  ///
  /// In de, this message translates to:
  /// **'Verlängerung'**
  String get renewalLabel;

  /// No description provided for @deleteContractTitle.
  ///
  /// In de, this message translates to:
  /// **'Vertrag löschen?'**
  String get deleteContractTitle;

  /// No description provided for @deleteContractContent.
  ///
  /// In de, this message translates to:
  /// **'\"{name}\" wirklich dauerhaft löschen?'**
  String deleteContractContent(String name);

  /// No description provided for @cancellationCardTitle.
  ///
  /// In de, this message translates to:
  /// **'Kündigung'**
  String get cancellationCardTitle;

  /// No description provided for @cancellationMethodLabel.
  ///
  /// In de, this message translates to:
  /// **'Methode'**
  String get cancellationMethodLabel;

  /// No description provided for @cancellationPeriodLabel.
  ///
  /// In de, this message translates to:
  /// **'Frist'**
  String get cancellationPeriodLabel;

  /// No description provided for @cancellationRenewalLabel.
  ///
  /// In de, this message translates to:
  /// **'Nächste Verlängerung'**
  String get cancellationRenewalLabel;

  /// No description provided for @cancellationInstructionsLabel.
  ///
  /// In de, this message translates to:
  /// **'Anleitung:'**
  String get cancellationInstructionsLabel;

  /// No description provided for @heirsTitle.
  ///
  /// In de, this message translates to:
  /// **'Erben & Teilen'**
  String get heirsTitle;

  /// No description provided for @heirsInfoText.
  ///
  /// In de, this message translates to:
  /// **'Hinterbliebene erhalten Zugang zu deinen Verträgen. Für den Fall der Fälle.'**
  String get heirsInfoText;

  /// No description provided for @heirsEmptyTitle.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Erben hinterlegt'**
  String get heirsEmptyTitle;

  /// No description provided for @heirsEmptySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Lege fest, wer im Fall der Fälle Zugang\nzu deinen Verträgen erhält.'**
  String get heirsEmptySubtitle;

  /// No description provided for @heirAddFab.
  ///
  /// In de, this message translates to:
  /// **'Erbe hinzufügen'**
  String get heirAddFab;

  /// No description provided for @exportPdfTooltip.
  ///
  /// In de, this message translates to:
  /// **'PDF exportieren'**
  String get exportPdfTooltip;

  /// No description provided for @exportedPath.
  ///
  /// In de, this message translates to:
  /// **'Exportiert: {path}'**
  String exportedPath(String path);

  /// No description provided for @noContractsToExport.
  ///
  /// In de, this message translates to:
  /// **'Keine Verträge zum Exportieren'**
  String get noContractsToExport;

  /// No description provided for @deleteHeirTitle.
  ///
  /// In de, this message translates to:
  /// **'Erbe löschen?'**
  String get deleteHeirTitle;

  /// No description provided for @deleteHeirContent.
  ///
  /// In de, this message translates to:
  /// **'{name} wirklich entfernen?'**
  String deleteHeirContent(String name);

  /// No description provided for @heirEditTitle.
  ///
  /// In de, this message translates to:
  /// **'Erbe bearbeiten'**
  String get heirEditTitle;

  /// No description provided for @heirAddTitle.
  ///
  /// In de, this message translates to:
  /// **'Erbe hinzufügen'**
  String get heirAddTitle;

  /// No description provided for @fieldPin.
  ///
  /// In de, this message translates to:
  /// **'PIN setzen'**
  String get fieldPin;

  /// No description provided for @fieldPinEdit.
  ///
  /// In de, this message translates to:
  /// **'Neuen PIN setzen (optional)'**
  String get fieldPinEdit;

  /// No description provided for @fieldPinHelper.
  ///
  /// In de, this message translates to:
  /// **'Mind. 6 Ziffern'**
  String get fieldPinHelper;

  /// No description provided for @fieldAccessLevel.
  ///
  /// In de, this message translates to:
  /// **'Zugangsstufe'**
  String get fieldAccessLevel;

  /// No description provided for @accessLevelsTitle.
  ///
  /// In de, this message translates to:
  /// **'Zugangsstufen erklärt:'**
  String get accessLevelsTitle;

  /// No description provided for @premiumDialogTitle.
  ///
  /// In de, this message translates to:
  /// **'Vollzugang freischalten'**
  String get premiumDialogTitle;

  /// No description provided for @premiumDialogContent.
  ///
  /// In de, this message translates to:
  /// **'Du hast die kostenlose Grenze von 5 Verträgen erreicht.\n\nMit dem Vollzugang verwaltest du beliebig viele Verträge — einmaliger Kauf, kein Abo.\n\nIm finalen Release: ~2,99 €'**
  String get premiumDialogContent;

  /// No description provided for @premiumLater.
  ///
  /// In de, this message translates to:
  /// **'Später'**
  String get premiumLater;

  /// No description provided for @premiumUnlock.
  ///
  /// In de, this message translates to:
  /// **'Jetzt kaufen'**
  String get premiumUnlock;

  /// No description provided for @premiumPurchaseFailed.
  ///
  /// In de, this message translates to:
  /// **'Kauf fehlgeschlagen. Bitte versuche es erneut.'**
  String get premiumPurchaseFailed;

  /// No description provided for @settingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settingsTitle;

  /// No description provided for @settingsSectionData.
  ///
  /// In de, this message translates to:
  /// **'Daten & Sync'**
  String get settingsSectionData;

  /// No description provided for @settingsCloudSync.
  ///
  /// In de, this message translates to:
  /// **'Cloud-Sync (Supabase)'**
  String get settingsCloudSync;

  /// No description provided for @settingsCloudSyncSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Verschlüsseltes Backup, AES-256'**
  String get settingsCloudSyncSubtitle;

  /// No description provided for @settingsVault.
  ///
  /// In de, this message translates to:
  /// **'Lebenszeichen-Tresor'**
  String get settingsVault;

  /// No description provided for @settingsVaultSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Automatische Weitergabe an Erben'**
  String get settingsVaultSubtitle;

  /// No description provided for @settingsHeirPasswordPolicy.
  ///
  /// In de, this message translates to:
  /// **'Login-Daten für Erben'**
  String get settingsHeirPasswordPolicy;

  /// No description provided for @settingsHeirPasswordPolicySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Wie kommen Erben an Benutzernamen und Passwörter?'**
  String get settingsHeirPasswordPolicySubtitle;

  /// No description provided for @heirPolicyTitle.
  ///
  /// In de, this message translates to:
  /// **'Login-Daten für Erben'**
  String get heirPolicyTitle;

  /// No description provided for @heirPolicyIntro.
  ///
  /// In de, this message translates to:
  /// **'Pacto kann pro Vertrag Benutzername und Passwort speichern, damit deine Erben im Ernstfall direkt kündigen können. Wähle, wie diese Daten geschützt werden — du kannst die Auswahl jederzeit ändern.'**
  String get heirPolicyIntro;

  /// No description provided for @heirPolicyNoneTitle.
  ///
  /// In de, this message translates to:
  /// **'Keine Passwörter speichern'**
  String get heirPolicyNoneTitle;

  /// No description provided for @heirPolicyNoneBody.
  ///
  /// In de, this message translates to:
  /// **'Nur ein Freitext-Hinweis pro Vertrag (z. B. „siehe 1Password\" oder „Notizbuch im Schreibtisch\"). Pacto speichert keine Login-Daten — du verwaltest sie anderswo.'**
  String get heirPolicyNoneBody;

  /// No description provided for @heirPolicyKomfortTitle.
  ///
  /// In de, this message translates to:
  /// **'Komfort: in der Mail im Klartext'**
  String get heirPolicyKomfortTitle;

  /// No description provided for @heirPolicyKomfortBody.
  ///
  /// In de, this message translates to:
  /// **'Passwörter werden verschlüsselt gespeichert. Im Erbfall entschlüsselt der Pacto-Server sie und packt sie in die E-Mail an deine Erben. Vertrauensmodell: du vertraust dem Pacto-Anbieter (vergleichbar mit iCloud / Google).'**
  String get heirPolicyKomfortBody;

  /// No description provided for @heirPolicyMaximumTitle.
  ///
  /// In de, this message translates to:
  /// **'Maximum: Erbe braucht PIN'**
  String get heirPolicyMaximumTitle;

  /// No description provided for @heirPolicyMaximumBody.
  ///
  /// In de, this message translates to:
  /// **'Passwörter werden mit einem Schlüssel verschlüsselt, der aus dem Erben-PIN abgeleitet wird. Der Pacto-Server kann nichts entschlüsseln. Wichtig: du musst jedem Erben den PIN vorab mitteilen (Brief, SMS, Notar). Sonst kommt er an die Daten nicht.'**
  String get heirPolicyMaximumBody;

  /// No description provided for @heirPolicySaved.
  ///
  /// In de, this message translates to:
  /// **'Einstellung gespeichert.'**
  String get heirPolicySaved;

  /// No description provided for @heirPolicyWarnPinShared.
  ///
  /// In de, this message translates to:
  /// **'Stelle sicher, dass deine Erben ihren PIN kennen — sonst können sie deine Passwörter nicht entschlüsseln.'**
  String get heirPolicyWarnPinShared;

  /// No description provided for @heirPolicyPurgeTitle.
  ///
  /// In de, this message translates to:
  /// **'Gespeicherte Passwörter entfernen?'**
  String get heirPolicyPurgeTitle;

  /// No description provided for @heirPolicyPurgeBody.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{Ein Vertrag hat ein gespeichertes Passwort.} other{{count} Verträge haben gespeicherte Passwörter.}} Da du \"Keine Passwörter speichern\" gewählt hast, kannst du sie jetzt aus Pacto entfernen. Benutzernamen und Hinweise bleiben erhalten.'**
  String heirPolicyPurgeBody(int count);

  /// No description provided for @heirPolicyPurgeKeep.
  ///
  /// In de, this message translates to:
  /// **'Behalten'**
  String get heirPolicyPurgeKeep;

  /// No description provided for @heirPolicyPurgeConfirm.
  ///
  /// In de, this message translates to:
  /// **'Passwörter löschen'**
  String get heirPolicyPurgeConfirm;

  /// No description provided for @heirPolicyPurgeDone.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Passwort entfernt.} other{{count} Passwörter entfernt.}}'**
  String heirPolicyPurgeDone(int count);

  /// No description provided for @sectionLogin.
  ///
  /// In de, this message translates to:
  /// **'Login-Daten'**
  String get sectionLogin;

  /// No description provided for @sectionLoginSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Optional — werden im Erbfall an die Erben weitergegeben'**
  String get sectionLoginSubtitle;

  /// No description provided for @fieldLoginUsername.
  ///
  /// In de, this message translates to:
  /// **'Benutzername / E-Mail'**
  String get fieldLoginUsername;

  /// No description provided for @fieldLoginPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get fieldLoginPassword;

  /// No description provided for @fieldLoginPasswordPlaceholderExisting.
  ///
  /// In de, this message translates to:
  /// **'•••••• (gespeichert)'**
  String get fieldLoginPasswordPlaceholderExisting;

  /// No description provided for @fieldLoginPasswordHintExisting.
  ///
  /// In de, this message translates to:
  /// **'Leer lassen, um das gespeicherte Passwort zu behalten.'**
  String get fieldLoginPasswordHintExisting;

  /// No description provided for @fieldLoginHint.
  ///
  /// In de, this message translates to:
  /// **'Hinweis (falls kein Passwort gespeichert ist)'**
  String get fieldLoginHint;

  /// No description provided for @fieldLoginHintHint.
  ///
  /// In de, this message translates to:
  /// **'z. B. \"siehe 1Password\" / \"Notizbuch im Schreibtisch\"'**
  String get fieldLoginHintHint;

  /// No description provided for @loginLastVerifiedNever.
  ///
  /// In de, this message translates to:
  /// **'Noch nicht bestätigt'**
  String get loginLastVerifiedNever;

  /// No description provided for @loginLastVerifiedRecent.
  ///
  /// In de, this message translates to:
  /// **'Bestätigt am {date}'**
  String loginLastVerifiedRecent(Object date);

  /// No description provided for @loginConfirmNowButton.
  ///
  /// In de, this message translates to:
  /// **'Jetzt als aktuell bestätigen'**
  String get loginConfirmNowButton;

  /// No description provided for @loginStaleWarning.
  ///
  /// In de, this message translates to:
  /// **'Seit über 6 Monaten nicht bestätigt — prüfen, ob das Passwort noch stimmt.'**
  String get loginStaleWarning;

  /// No description provided for @loginPolicyHintNone.
  ///
  /// In de, this message translates to:
  /// **'Du speicherst aktuell keine Passwörter (Einstellung: \"Keine Passwörter speichern\"). Nur das Hinweis-Feld wird in der Erben-Mail erscheinen.'**
  String get loginPolicyHintNone;

  /// No description provided for @loginPolicyHintKomfort.
  ///
  /// In de, this message translates to:
  /// **'Passwörter landen im Erbfall im Klartext in der Erben-Mail (Komfort-Modus).'**
  String get loginPolicyHintKomfort;

  /// No description provided for @loginPolicyHintMaximum.
  ///
  /// In de, this message translates to:
  /// **'Passwörter werden mit dem Erben-PIN verschlüsselt — Erbe braucht den PIN.'**
  String get loginPolicyHintMaximum;

  /// No description provided for @loginCardTitle.
  ///
  /// In de, this message translates to:
  /// **'Login-Daten'**
  String get loginCardTitle;

  /// No description provided for @loginCopied.
  ///
  /// In de, this message translates to:
  /// **'In Zwischenablage kopiert'**
  String get loginCopied;

  /// No description provided for @loginRevealError.
  ///
  /// In de, this message translates to:
  /// **'Passwort konnte nicht entschlüsselt werden.'**
  String get loginRevealError;

  /// No description provided for @loginPasswordStored.
  ///
  /// In de, this message translates to:
  /// **'Passwort gespeichert'**
  String get loginPasswordStored;

  /// No description provided for @heirExportPreviewButton.
  ///
  /// In de, this message translates to:
  /// **'Vorschau für diesen Erben'**
  String get heirExportPreviewButton;

  /// No description provided for @heirExportPreviewTitle.
  ///
  /// In de, this message translates to:
  /// **'So sieht die Erben-Mail aus'**
  String get heirExportPreviewTitle;

  /// No description provided for @heirExportPinPromptTitle.
  ///
  /// In de, this message translates to:
  /// **'Erben-PIN nötig'**
  String get heirExportPinPromptTitle;

  /// No description provided for @heirExportPinPromptBody.
  ///
  /// In de, this message translates to:
  /// **'Im Maximum-Modus wird das Passwort mit dem Erben-PIN verschlüsselt. Gib den PIN ein, den du diesem Erben mitgeteilt hast.'**
  String get heirExportPinPromptBody;

  /// No description provided for @heirExportPinPromptField.
  ///
  /// In de, this message translates to:
  /// **'Erben-PIN'**
  String get heirExportPinPromptField;

  /// No description provided for @heirExportPinPromptButton.
  ///
  /// In de, this message translates to:
  /// **'Vorschau erzeugen'**
  String get heirExportPinPromptButton;

  /// No description provided for @heirExportCancel.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get heirExportCancel;

  /// No description provided for @heirExportCopyAll.
  ///
  /// In de, this message translates to:
  /// **'Alles kopieren'**
  String get heirExportCopyAll;

  /// No description provided for @settingsSectionApp.
  ///
  /// In de, this message translates to:
  /// **'App'**
  String get settingsSectionApp;

  /// No description provided for @settingsReplay.
  ///
  /// In de, this message translates to:
  /// **'Einführung wiederholen'**
  String get settingsReplay;

  /// No description provided for @settingsVersion.
  ///
  /// In de, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsPrivacy.
  ///
  /// In de, this message translates to:
  /// **'Datenschutz'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Daten bleiben lokal auf deinem Gerät'**
  String get settingsPrivacySubtitle;

  /// No description provided for @settingsSectionFreemium.
  ///
  /// In de, this message translates to:
  /// **'Freemium'**
  String get settingsSectionFreemium;

  /// No description provided for @settingsFullAccess.
  ///
  /// In de, this message translates to:
  /// **'Vollzugang freigeschaltet'**
  String get settingsFullAccess;

  /// No description provided for @settingsFullAccessSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Unbegrenzt viele Verträge'**
  String get settingsFullAccessSubtitle;

  /// No description provided for @settingsUnlockFull.
  ///
  /// In de, this message translates to:
  /// **'Vollzugang freischalten'**
  String get settingsUnlockFull;

  /// No description provided for @settingsUnlockSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Mehr als 5 Verträge · einmalig ~2,99 €'**
  String get settingsUnlockSubtitle;

  /// No description provided for @settingsBuyButton.
  ///
  /// In de, this message translates to:
  /// **'Kaufen'**
  String get settingsBuyButton;

  /// No description provided for @settingsRestorePurchase.
  ///
  /// In de, this message translates to:
  /// **'Kauf wiederherstellen'**
  String get settingsRestorePurchase;

  /// No description provided for @settingsRestoreSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Falls du die App neu installiert hast'**
  String get settingsRestoreSubtitle;

  /// No description provided for @settingsRestoreSuccess.
  ///
  /// In de, this message translates to:
  /// **'Vollzugang wiederhergestellt!'**
  String get settingsRestoreSuccess;

  /// No description provided for @settingsRestoreNotFound.
  ///
  /// In de, this message translates to:
  /// **'Kein früherer Kauf gefunden.'**
  String get settingsRestoreNotFound;

  /// No description provided for @settingsResetPurchase.
  ///
  /// In de, this message translates to:
  /// **'Kauf zurücksetzen (Debug)'**
  String get settingsResetPurchase;

  /// No description provided for @settingsResetSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Nur auf Desktop — entfernt den Vollzugang lokal'**
  String get settingsResetSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Deutsch / English'**
  String get settingsLanguageSubtitle;

  /// No description provided for @langSystem.
  ///
  /// In de, this message translates to:
  /// **'Systemsprache'**
  String get langSystem;

  /// No description provided for @langDe.
  ///
  /// In de, this message translates to:
  /// **'Deutsch'**
  String get langDe;

  /// No description provided for @langEn.
  ///
  /// In de, this message translates to:
  /// **'English'**
  String get langEn;

  /// No description provided for @cloudSyncTitle.
  ///
  /// In de, this message translates to:
  /// **'Cloud-Sync'**
  String get cloudSyncTitle;

  /// No description provided for @cloudEncryptionTitle.
  ///
  /// In de, this message translates to:
  /// **'AES-256 verschlüsselt'**
  String get cloudEncryptionTitle;

  /// No description provided for @cloudEncryptionDesc.
  ///
  /// In de, this message translates to:
  /// **'Deine Daten werden vor dem Upload mit AES-256-GCM verschlüsselt. Der Schlüssel bleibt lokal auf deinem Gerät — in der Pacto-Cloud liegen nur unlesbare Daten.'**
  String get cloudEncryptionDesc;

  /// No description provided for @syncToggle.
  ///
  /// In de, this message translates to:
  /// **'Sync aktivieren'**
  String get syncToggle;

  /// No description provided for @syncToggleSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Verschlüsseltes Backup in der Pacto-Cloud'**
  String get syncToggleSubtitle;

  /// No description provided for @syncLastSync.
  ///
  /// In de, this message translates to:
  /// **'Letzter Sync'**
  String get syncLastSync;

  /// No description provided for @syncNever.
  ///
  /// In de, this message translates to:
  /// **'noch nie'**
  String get syncNever;

  /// No description provided for @syncNowButton.
  ///
  /// In de, this message translates to:
  /// **'Jetzt synchronisieren'**
  String get syncNowButton;

  /// No description provided for @syncSuccess.
  ///
  /// In de, this message translates to:
  /// **'Sync erfolgreich'**
  String get syncSuccess;

  /// No description provided for @syncReadyNote.
  ///
  /// In de, this message translates to:
  /// **'Cloud-Backup ist startklar konfiguriert — keine Einrichtung nötig. Du musst Sync nur aktivieren.'**
  String get syncReadyNote;

  /// No description provided for @vaultTitle.
  ///
  /// In de, this message translates to:
  /// **'Lebenszeichen-Tresor'**
  String get vaultTitle;

  /// No description provided for @vaultInfoTitle.
  ///
  /// In de, this message translates to:
  /// **'Für den Fall der Fälle'**
  String get vaultInfoTitle;

  /// No description provided for @vaultInfoDesc.
  ///
  /// In de, this message translates to:
  /// **'Wenn du eine Weile nicht mehr aktiv warst, erhalten deine hinterlegten Erben automatisch Zugang. Jede App-Nutzung und der Button unten bestätigen, dass alles in Ordnung ist.'**
  String get vaultInfoDesc;

  /// No description provided for @vaultToggle.
  ///
  /// In de, this message translates to:
  /// **'Tresor aktivieren'**
  String get vaultToggle;

  /// No description provided for @vaultToggleSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Benötigt aktivierten Cloud-Sync für die Weitergabe'**
  String get vaultToggleSubtitle;

  /// No description provided for @vaultLastConfirmed.
  ///
  /// In de, this message translates to:
  /// **'Letzte Bestätigung'**
  String get vaultLastConfirmed;

  /// No description provided for @vaultExpiry.
  ///
  /// In de, this message translates to:
  /// **'Frist läuft ab'**
  String get vaultExpiry;

  /// No description provided for @vaultNever.
  ///
  /// In de, this message translates to:
  /// **'noch nie'**
  String get vaultNever;

  /// No description provided for @vaultConfirmButton.
  ///
  /// In de, this message translates to:
  /// **'Mir geht es gut — Frist zurücksetzen'**
  String get vaultConfirmButton;

  /// No description provided for @vaultConfirmSnackbar.
  ///
  /// In de, this message translates to:
  /// **'Lebenszeichen aktualisiert'**
  String get vaultConfirmSnackbar;

  /// No description provided for @vaultIntervalLabel.
  ///
  /// In de, this message translates to:
  /// **'Intervall'**
  String get vaultIntervalLabel;

  /// No description provided for @vaultIntervalDays.
  ///
  /// In de, this message translates to:
  /// **'{days} Tage'**
  String vaultIntervalDays(int days);

  /// No description provided for @vaultServerTitle.
  ///
  /// In de, this message translates to:
  /// **'Server-seitiger Trigger'**
  String get vaultServerTitle;

  /// No description provided for @vaultServerDesc.
  ///
  /// In de, this message translates to:
  /// **'Die automatische Weiterleitung an die Erben übernimmt eine Supabase-Edge-Function (pg_cron + PDF-Generierung + E-Mail-Versand). Diese Komponente ist außerhalb der App vorbereitet und nicht Teil der lokalen Installation.'**
  String get vaultServerDesc;

  /// No description provided for @vaultOwnerEmailLabel.
  ///
  /// In de, this message translates to:
  /// **'Deine E-Mail für Vorwarnungen'**
  String get vaultOwnerEmailLabel;

  /// No description provided for @vaultOwnerEmailHint.
  ///
  /// In de, this message translates to:
  /// **'An diese Adresse senden wir kurz vor Auslösung eine Warnmail.'**
  String get vaultOwnerEmailHint;

  /// No description provided for @vaultOwnerEmailRequired.
  ///
  /// In de, this message translates to:
  /// **'E-Mail-Adresse fehlt — ohne sie kann der Tresor nicht warnen.'**
  String get vaultOwnerEmailRequired;

  /// No description provided for @vaultSyncNowButton.
  ///
  /// In de, this message translates to:
  /// **'Erbendaten jetzt hochladen'**
  String get vaultSyncNowButton;

  /// No description provided for @vaultSyncSuccess.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Erben-Brief im Tresor abgelegt.} other{{count} Erben-Briefe im Tresor abgelegt.}}'**
  String vaultSyncSuccess(int count);

  /// No description provided for @vaultLastSyncLabel.
  ///
  /// In de, this message translates to:
  /// **'Zuletzt synchronisiert'**
  String get vaultLastSyncLabel;

  /// No description provided for @vaultLastSyncNever.
  ///
  /// In de, this message translates to:
  /// **'noch nicht'**
  String get vaultLastSyncNever;

  /// No description provided for @onboardingSkip.
  ///
  /// In de, this message translates to:
  /// **'Überspringen'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In de, this message translates to:
  /// **'Loslegen'**
  String get onboardingStart;

  /// No description provided for @onboardingNameTitle.
  ///
  /// In de, this message translates to:
  /// **'Wie heißt du?'**
  String get onboardingNameTitle;

  /// No description provided for @onboardingNameBody.
  ///
  /// In de, this message translates to:
  /// **'So kann Pacto dich persönlich begrüßen.'**
  String get onboardingNameBody;

  /// No description provided for @onboardingNameHint.
  ///
  /// In de, this message translates to:
  /// **'Dein Vorname'**
  String get onboardingNameHint;

  /// No description provided for @onboardingNameSkip.
  ///
  /// In de, this message translates to:
  /// **'Lieber anonym bleiben'**
  String get onboardingNameSkip;

  /// No description provided for @onboarding1Title.
  ///
  /// In de, this message translates to:
  /// **'Weißt du wirklich was du jeden Monat zahlst?'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Body.
  ///
  /// In de, this message translates to:
  /// **'Pacto sammelt alle deine Abos und Verträge an einem Ort — mit Kosten, Kündigungsfristen und Anleitung zur Beendigung.'**
  String get onboarding1Body;

  /// No description provided for @onboarding2Title.
  ///
  /// In de, this message translates to:
  /// **'Foto rein — Daten raus'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Body.
  ///
  /// In de, this message translates to:
  /// **'Mach ein Foto vom Vertrag oder teile ein PDF an Pacto. Die KI füllt das Formular automatisch aus.'**
  String get onboarding2Body;

  /// No description provided for @onboarding3Title.
  ///
  /// In de, this message translates to:
  /// **'Für den Fall der Fälle'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Body.
  ///
  /// In de, this message translates to:
  /// **'Hinterlege Erben mit PIN-Zugang. So weiß im Ernstfall sofort jemand Bescheid — ruhig, sicher, nur dann zugänglich, wenn nötig.'**
  String get onboarding3Body;

  /// No description provided for @webSearchUnsupportedPlatform.
  ///
  /// In de, this message translates to:
  /// **'Die Web-Suche ist nur auf Mobilgeräten (Android, iOS) und macOS verfügbar.\n\nAuf dem Desktop kannst du Verträge manuell einpflegen.'**
  String get webSearchUnsupportedPlatform;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
