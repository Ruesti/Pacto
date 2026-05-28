import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/database/daos/contracts_dao.dart';
import '../../data/providers/database_provider.dart';
import '../../data/sync/crypto_service.dart';
import '../provider_library/provider_library_data.dart';
import '../scan/extraction_result.dart';

class AddContractState {
  final String name;
  final String provider;
  final ContractCategory category;
  final double monthlyCost;
  final BillingCycle billingCycle;
  final CancellationMethod cancellationMethod;
  final String cancellationInstructions;
  final String noticePeriod;
  final String? contactPhone;
  final String? contactEmail;
  final String? contactUrl;
  final String notes;
  final DateTime? contractStart;
  final DateTime? nextRenewal;
  // ─── Login-Daten ───
  // Username im Klartext (allein nicht sensibel).
  final String? loginUsername;
  // Freitext-Hinweis falls der User keine Passwoerter speichern moechte.
  final String? loginHint;
  final DateTime? loginLastVerifiedAt;
  // Beim Bearbeiten halten wir den vorhandenen Cipher-Envelope (kommt aus
  // dem DB-Datensatz). Wir entschluesseln ihn NICHT in den Editor — der
  // User tippt entweder ein neues Passwort (loginPasswordNew != null) oder
  // laesst das alte unangetastet.
  final String? loginPasswordCt;
  // Vom User in der UI eingegebener neuer Klartext.
  //   null  → unveraendert, alter Ciphertext bleibt erhalten.
  //   ''    → explizit geloescht.
  //   sonst → neuer Wert (wird beim Speichern verschluesselt).
  final String? loginPasswordNew;
  final bool isSubmitting;
  final String? error;

  const AddContractState({
    this.name = '',
    this.provider = '',
    this.category = ContractCategory.sonstiges,
    this.monthlyCost = 0.0,
    this.billingCycle = BillingCycle.monthly,
    this.cancellationMethod = CancellationMethod.online,
    this.cancellationInstructions = '',
    this.noticePeriod = '',
    this.contactPhone,
    this.contactEmail,
    this.contactUrl,
    this.notes = '',
    this.contractStart,
    this.nextRenewal,
    this.loginUsername,
    this.loginHint,
    this.loginLastVerifiedAt,
    this.loginPasswordCt,
    this.loginPasswordNew,
    this.isSubmitting = false,
    this.error,
  });

  AddContractState copyWith({
    String? name,
    String? provider,
    ContractCategory? category,
    double? monthlyCost,
    BillingCycle? billingCycle,
    CancellationMethod? cancellationMethod,
    String? cancellationInstructions,
    String? noticePeriod,
    String? contactPhone,
    String? contactEmail,
    String? contactUrl,
    String? notes,
    DateTime? contractStart,
    DateTime? nextRenewal,
    String? loginUsername,
    String? loginHint,
    DateTime? loginLastVerifiedAt,
    String? loginPasswordCt,
    Object? loginPasswordNew = _absent,
    bool? isSubmitting,
    String? error,
  }) =>
      AddContractState(
        name: name ?? this.name,
        provider: provider ?? this.provider,
        category: category ?? this.category,
        monthlyCost: monthlyCost ?? this.monthlyCost,
        billingCycle: billingCycle ?? this.billingCycle,
        cancellationMethod: cancellationMethod ?? this.cancellationMethod,
        cancellationInstructions:
            cancellationInstructions ?? this.cancellationInstructions,
        noticePeriod: noticePeriod ?? this.noticePeriod,
        contactPhone: contactPhone ?? this.contactPhone,
        contactEmail: contactEmail ?? this.contactEmail,
        contactUrl: contactUrl ?? this.contactUrl,
        notes: notes ?? this.notes,
        contractStart: contractStart ?? this.contractStart,
        nextRenewal: nextRenewal ?? this.nextRenewal,
        loginUsername: loginUsername ?? this.loginUsername,
        loginHint: loginHint ?? this.loginHint,
        loginLastVerifiedAt: loginLastVerifiedAt ?? this.loginLastVerifiedAt,
        loginPasswordCt: loginPasswordCt ?? this.loginPasswordCt,
        loginPasswordNew: identical(loginPasswordNew, _absent)
            ? this.loginPasswordNew
            : loginPasswordNew as String?,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: error,
      );

  bool get isValid => name.isNotEmpty && provider.isNotEmpty;
}

const _absent = Object();

class AddContractNotifier extends StateNotifier<AddContractState> {
  final ContractsDao _dao;
  final CryptoService _crypto;
  final String? _editingId;

  AddContractNotifier(
    this._dao,
    this._crypto, {
    String? editingId,
    Contract? existing,
  })  : _editingId = editingId,
        super(existing != null
            ? AddContractState(
                name: existing.name,
                provider: existing.provider,
                category: existing.category,
                monthlyCost: existing.monthlyCost,
                billingCycle: existing.billingCycle,
                cancellationMethod: existing.cancellationMethod,
                cancellationInstructions: existing.cancellationInstructions,
                noticePeriod: existing.noticePeriod,
                contactPhone: existing.contactPhone,
                contactEmail: existing.contactEmail,
                contactUrl: existing.contactUrl,
                notes: existing.notes,
                contractStart: existing.contractStart,
                nextRenewal: existing.nextRenewal,
                loginUsername: existing.loginUsername,
                loginHint: existing.loginHint,
                loginLastVerifiedAt: existing.loginLastVerifiedAt,
                loginPasswordCt: existing.loginPasswordCt,
              )
            : const AddContractState());

  void prefillFromTemplate(ProviderTemplate t) {
    state = state.copyWith(
      name: t.name,
      provider: t.provider,
      category: t.category,
      cancellationMethod: t.cancellationMethod,
      cancellationInstructions: t.cancellationInstructions,
      noticePeriod: t.noticePeriod,
      contactPhone: t.contactPhone,
      contactEmail: t.contactEmail,
      contactUrl: t.contactUrl,
    );
  }

  void prefillFromExtractionResult(ExtractionResult r) {
    state = state.copyWith(
      name: r.name,
      provider: r.provider,
      category: r.category,
      monthlyCost: r.monthlyCost,
      billingCycle: r.billingCycle,
      cancellationMethod: r.cancellationMethod,
      cancellationInstructions: r.cancellationInstructions,
      noticePeriod: r.noticePeriod,
      contactPhone: r.contactPhone,
      contactEmail: r.contactEmail,
      contactUrl: r.contactUrl,
      notes: r.notes,
      nextRenewal: r.nextRenewal,
    );
  }

  void setName(String v) => state = state.copyWith(name: v);
  void setProvider(String v) => state = state.copyWith(provider: v);
  void setCategory(ContractCategory v) => state = state.copyWith(category: v);
  void setBillingCycle(BillingCycle v) => state = state.copyWith(billingCycle: v);
  void setCancellationMethod(CancellationMethod v) =>
      state = state.copyWith(cancellationMethod: v);
  void setCancellationInstructions(String v) =>
      state = state.copyWith(cancellationInstructions: v);
  void setNoticePeriod(String v) => state = state.copyWith(noticePeriod: v);
  void setContactPhone(String? v) => state = state.copyWith(contactPhone: v);
  void setContactEmail(String? v) => state = state.copyWith(contactEmail: v);
  void setContactUrl(String? v) => state = state.copyWith(contactUrl: v);
  void setNotes(String v) => state = state.copyWith(notes: v);
  void setContractStart(DateTime? v) => state = state.copyWith(contractStart: v);
  void setNextRenewal(DateTime? v) => state = state.copyWith(nextRenewal: v);
  void setLoginUsername(String? v) =>
      state = state.copyWith(loginUsername: v);
  void setLoginHint(String? v) => state = state.copyWith(loginHint: v);
  void setLoginPasswordNew(String? v) =>
      state = state.copyWith(loginPasswordNew: v);
  void markLoginVerifiedNow() =>
      state = state.copyWith(loginLastVerifiedAt: DateTime.now());

  void setMonthlyCostFromInput(String raw, BillingCycle cycle) {
    final parsed = double.tryParse(raw.replaceAll(',', '.')) ?? 0.0;
    final monthly = cycle == BillingCycle.yearly
        ? parsed / 12
        : cycle == BillingCycle.quarterly
            ? parsed / 3
            : cycle == BillingCycle.weekly
                ? parsed * 4.33
                : parsed;
    state = state.copyWith(monthlyCost: monthly);
  }

  // Errechnet aus alter Cipher + neuem Klartext den endgueltigen Ciphertext.
  // null  → user hat nichts angefasst → alten Wert behalten
  // ''    → user hat explizit geleert → null speichern (Passwort entfernen)
  // sonst → neuen Wert verschluesseln
  Future<String?> _resolveFinalPasswordCt() async {
    final newValue = state.loginPasswordNew;
    if (newValue == null) return state.loginPasswordCt;
    if (newValue.isEmpty) return null;
    return _crypto.encryptString(newValue);
  }

  Future<bool> save() async {
    if (!state.isValid) return false;
    state = state.copyWith(isSubmitting: true);
    try {
      final now = DateTime.now();
      final passwordCt = await _resolveFinalPasswordCt();
      // Wenn der User ein neues Passwort gesetzt hat, gilt es ab jetzt als
      // gerade-bestaetigt — sonst behalten wir den vorhandenen Zeitstempel.
      final verifiedAt = state.loginPasswordNew != null &&
              state.loginPasswordNew!.isNotEmpty
          ? now
          : state.loginLastVerifiedAt;

      if (_editingId != null) {
        await _dao.updateContract(ContractsCompanion(
          id: Value(_editingId),
          name: Value(state.name),
          provider: Value(state.provider),
          category: Value(state.category),
          monthlyCost: Value(state.monthlyCost),
          billingCycle: Value(state.billingCycle),
          cancellationMethod: Value(state.cancellationMethod),
          cancellationInstructions: Value(state.cancellationInstructions),
          noticePeriod: Value(state.noticePeriod),
          contactPhone: Value(state.contactPhone),
          contactEmail: Value(state.contactEmail),
          contactUrl: Value(state.contactUrl),
          notes: Value(state.notes),
          contractStart: Value(state.contractStart),
          nextRenewal: Value(state.nextRenewal),
          loginUsername: Value(state.loginUsername),
          loginPasswordCt: Value(passwordCt),
          loginHint: Value(state.loginHint),
          loginLastVerifiedAt: Value(verifiedAt),
          updatedAt: Value(now),
        ));
      } else {
        await _dao.insertContract(ContractsCompanion.insert(
          name: state.name,
          provider: state.provider,
          category: Value(state.category),
          monthlyCost: Value(state.monthlyCost),
          billingCycle: Value(state.billingCycle),
          cancellationMethod: Value(state.cancellationMethod),
          cancellationInstructions: Value(state.cancellationInstructions),
          noticePeriod: Value(state.noticePeriod),
          contactPhone: Value(state.contactPhone),
          contactEmail: Value(state.contactEmail),
          contactUrl: Value(state.contactUrl),
          notes: Value(state.notes),
          contractStart: Value(state.contractStart),
          nextRenewal: Value(state.nextRenewal),
          loginUsername: Value(state.loginUsername),
          loginPasswordCt: Value(passwordCt),
          loginHint: Value(state.loginHint),
          loginLastVerifiedAt: Value(verifiedAt),
        ));
      }
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final addContractProvider = StateNotifierProvider.autoDispose
    .family<AddContractNotifier, AddContractState, Contract?>(
  (ref, existing) => AddContractNotifier(
    ref.watch(contractsDaoProvider),
    ref.watch(cryptoServiceProvider),
    editingId: existing?.id,
    existing: existing,
  ),
);
