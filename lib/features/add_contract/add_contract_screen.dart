import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/providers/database_provider.dart';
import '../../data/providers/heir_password_policy_provider.dart';
import '../../shared/l10n/enum_labels.dart';
import '../../shared/l10n/l10n_extension.dart';
import '../../shared/theme/app_colors.dart';
import '../premium/premium_service.dart';
import '../provider_library/provider_library_data.dart';
import '../provider_library/provider_library_screen.dart';
import '../scan/extraction_result.dart';
import '../scan/scan_controller.dart';
import '../scan/web_search_screen.dart';
import 'add_contract_provider.dart';

class AddContractScreen extends ConsumerStatefulWidget {
  final Contract? existing;
  final ExtractionResult? initialExtraction;
  // Vorausgewaehlte Bibliotheks-Vorlage — fuellt beim Oeffnen alle bekannten
  // Standardfelder (Name, Anbieter, Kategorie, Kuendigung, Kontakt) vor.
  final ProviderTemplate? initialTemplate;
  // Nur fuer NEUE Eintraege relevant — bei bestehenden gilt existing.entryType.
  final EntryType entryType;

  const AddContractScreen({
    super.key,
    this.existing,
    this.initialExtraction,
    this.initialTemplate,
    this.entryType = EntryType.vertrag,
  });

  @override
  ConsumerState<AddContractScreen> createState() => _AddContractScreenState();
}

class _AddContractScreenState extends ConsumerState<AddContractScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _providerCtrl;
  late final TextEditingController _costCtrl;
  late final TextEditingController _cancInstructCtrl;
  late final TextEditingController _noticePeriodCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _urlCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _loginUsernameCtrl;
  late final TextEditingController _loginPasswordCtrl;
  late final TextEditingController _loginHintCtrl;
  bool _passwordObscured = true;
  final _formKey = GlobalKey<FormState>();
  ExtractionConfidence? _extractionConfidence;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _providerCtrl = TextEditingController(text: e?.provider ?? '');
    // Das Feld zeigt den Betrag pro Abrechnungsintervall (wie gezahlt), nicht
    // den normalisierten Monatsbetrag — sonst wuerde setMonthlyCostFromInput
    // beim Speichern einen Jahres-/Quartalsvertrag erneut durch 12/3 teilen.
    _costCtrl = TextEditingController(
        text: e != null
            ? e.billingCycle.billedFrom(e.monthlyCost).toStringAsFixed(2)
            : '');
    _cancInstructCtrl =
        TextEditingController(text: e?.cancellationInstructions ?? '');
    _noticePeriodCtrl = TextEditingController(text: e?.noticePeriod ?? '');
    _phoneCtrl = TextEditingController(text: e?.contactPhone ?? '');
    _emailCtrl = TextEditingController(text: e?.contactEmail ?? '');
    _urlCtrl = TextEditingController(text: e?.contactUrl ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _loginUsernameCtrl =
        TextEditingController(text: e?.loginUsername ?? '');
    _loginPasswordCtrl = TextEditingController();
    _loginHintCtrl = TextEditingController(text: e?.loginHint ?? '');

    // Neuer Zugang: entryType in den State seeden (bestehende Eintraege
    // bringen ihren Typ ueber den `existing`-Konstruktor selbst mit).
    if (widget.existing == null && widget.entryType != EntryType.vertrag) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _notifier.setEntryType(widget.entryType);
      });
    }

    if (widget.initialExtraction != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _applyExtractionResult(widget.initialExtraction!);
      });
    }

    if (widget.initialTemplate != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _applyTemplate(widget.initialTemplate!);
      });
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _providerCtrl, _costCtrl, _cancInstructCtrl,
      _noticePeriodCtrl, _phoneCtrl, _emailCtrl, _urlCtrl, _notesCtrl,
      _loginUsernameCtrl, _loginPasswordCtrl, _loginHintCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  AddContractNotifier get _notifier =>
      ref.read(addContractProvider(widget.existing).notifier);

  void _syncControllersToState() {
    _notifier.setName(_nameCtrl.text);
    _notifier.setProvider(_providerCtrl.text);
    _notifier.setCancellationInstructions(_cancInstructCtrl.text);
    _notifier.setNoticePeriod(_noticePeriodCtrl.text);
    _notifier.setContactPhone(
        _phoneCtrl.text.isEmpty ? null : _phoneCtrl.text);
    _notifier.setContactEmail(
        _emailCtrl.text.isEmpty ? null : _emailCtrl.text);
    _notifier.setContactUrl(_urlCtrl.text.isEmpty ? null : _urlCtrl.text);
    _notifier.setNotes(_notesCtrl.text);
    _notifier.setLoginUsername(
        _loginUsernameCtrl.text.isEmpty ? null : _loginUsernameCtrl.text);
    _notifier.setLoginHint(
        _loginHintCtrl.text.isEmpty ? null : _loginHintCtrl.text);
    // Passwort wird nur uebernommen wenn der User tatsaechlich getippt hat.
    // Leeres Feld + vorhandener Ciphertext → wir lassen das alte Passwort
    // unangetastet (loginPasswordNew bleibt null).
    if (_loginPasswordCtrl.text.isNotEmpty) {
      _notifier.setLoginPasswordNew(_loginPasswordCtrl.text);
    }
  }

  Future<void> _openLibrary() async {
    final template = await Navigator.of(context).push<ProviderTemplate>(
        MaterialPageRoute(builder: (_) => const ProviderLibraryScreen()));
    if (template == null) return;
    _applyTemplate(template);
  }

  // Uebernimmt eine Bibliotheks-Vorlage in State + Controller. Preis/Zyklus
  // sind in der Bibliothek bewusst nicht hinterlegt (variieren je Tarif) — die
  // tippt der Nutzer, ebenso Benutzername/Passwort.
  void _applyTemplate(ProviderTemplate template) {
    final lang = Localizations.localeOf(context).languageCode;
    _notifier.prefillFromTemplate(template, lang: lang);
    final state = ref.read(addContractProvider(widget.existing));
    _nameCtrl.text = state.name;
    _providerCtrl.text = state.provider;
    _cancInstructCtrl.text = state.cancellationInstructions;
    _noticePeriodCtrl.text = state.noticePeriod;
    _phoneCtrl.text = state.contactPhone ?? '';
    _emailCtrl.text = state.contactEmail ?? '';
    _urlCtrl.text = state.contactUrl ?? '';
    setState(() {});
  }

  Future<void> _openScan() async {
    final result = await Navigator.of(context).push<ExtractionResult>(
        MaterialPageRoute(builder: (_) => const ScanScreen()));
    if (result == null) return;
    _applyExtractionResult(result);
  }

  void _openWebSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WebSearchScreen()),
    );
  }

  void _applyExtractionResult(ExtractionResult result) {
    _notifier.prefillFromExtractionResult(result);
    final state = ref.read(addContractProvider(widget.existing));
    _nameCtrl.text = state.name;
    _providerCtrl.text = state.provider;
    _costCtrl.text = state.monthlyCost > 0
        ? state.billingCycle.billedFrom(state.monthlyCost).toStringAsFixed(2)
        : '';
    _cancInstructCtrl.text = state.cancellationInstructions;
    _noticePeriodCtrl.text = state.noticePeriod;
    _phoneCtrl.text = state.contactPhone ?? '';
    _emailCtrl.text = state.contactEmail ?? '';
    _urlCtrl.text = state.contactUrl ?? '';
    _notesCtrl.text = state.notes;
    setState(() => _extractionConfidence = result.confidence);
  }

  Future<bool> _passesFreemiumGate() async {
    if (widget.existing != null) return true;
    if (ref.read(premiumProvider).valueOrNull ?? false) return true;
    final count = (await ref.read(contractsDaoProvider).getAll()).length;
    if (count < freeTierLimit) return true;
    if (!mounted) return false;
    return showPurchaseDialog(context, ref);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!await _passesFreemiumGate()) return;
    _syncControllersToState();
    final state = ref.read(addContractProvider(widget.existing));
    // Zugaenge haben kein Kostenfeld — Kosten bleiben 0.
    if (state.entryType.isVertrag) {
      _notifier.setMonthlyCostFromInput(_costCtrl.text, state.billingCycle);
    }
    final ok = await _notifier.save();
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final state = ref.watch(addContractProvider(widget.existing));
    final isEdit = widget.existing != null;
    final isZugang = state.entryType.isZugang;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit
            ? (isZugang ? l.editAccessTitle : l.editContractTitle)
            : (isZugang ? l.addAccessTitle : l.addContractTitle)),
        actions: [
          // Bibliothek/Scan/Web ergeben fuer Zugaenge keinen Sinn.
          if (!isEdit && !isZugang) ...[
            IconButton(
              icon: const Icon(Icons.list_alt_outlined),
              tooltip: l.entryLibrary,
              onPressed: _openLibrary,
            ),
            IconButton(
              icon: const Icon(Icons.document_scanner_outlined),
              tooltip: l.entryScan,
              onPressed: _openScan,
            ),
            IconButton(
              icon: const Icon(Icons.public_outlined),
              tooltip: l.entryWebSearch,
              onPressed: _openWebSearch,
            ),
          ],
          TextButton(
            onPressed: state.isSubmitting ? null : _save,
            child: Text(l.saveButton),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_extractionConfidence != null)
              _confidenceBanner(_extractionConfidence!, l),
            _sectionHeader(l.sectionBasic),
            // Vertrag vs. Abo waehlt der Nutzer selbst (nur fuer Vertraege,
            // nicht fuer eigenstaendige Zugaenge).
            if (!isZugang) ...[
              SegmentedButton<ContractKind>(
                segments: [
                  ButtonSegment(
                    value: ContractKind.vertrag,
                    label: Text(l.kindVertrag),
                    icon: const Icon(Icons.description_outlined),
                  ),
                  ButtonSegment(
                    value: ContractKind.abo,
                    label: Text(l.kindAbo),
                    icon: const Icon(Icons.autorenew),
                  ),
                ],
                selected: {state.contractKind},
                onSelectionChanged: (s) =>
                    _notifier.setContractKind(s.first),
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                  labelText: isZugang ? l.fieldAccessName : '${l.fieldName} *'),
              validator: (v) =>
                  v?.isEmpty ?? true ? l.validationNameRequired : null,
              onChanged: _notifier.setName,
            ),
            const SizedBox(height: 12),
            // Anbieter + Kategorie sind nur fuer Vertraege/Abos relevant — ein
            // Zugang braucht nur Name, Benutzername und Passwort.
            if (!isZugang) ...[
              TextFormField(
                controller: _providerCtrl,
                decoration: InputDecoration(
                    labelText: '${l.fieldProvider} *'),
                validator: (v) =>
                    v?.isEmpty ?? true ? l.validationProviderRequired : null,
                onChanged: _notifier.setProvider,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ContractCategory>(
                initialValue: state.category,
                decoration: InputDecoration(labelText: l.fieldCategory),
                items: ContractCategory.values
                    .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.localizedLabel(l))))
                    .toList(),
                onChanged: (v) => _notifier.setCategory(v!),
              ),
            ],
            if (!isZugang) ...[
              const SizedBox(height: 24),
              _sectionHeader(l.sectionCost),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _costCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: InputDecoration(
                      labelText: l.fieldAmount,
                      suffixText: '€',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<BillingCycle>(
                    initialValue: state.billingCycle,
                    decoration: InputDecoration(labelText: l.fieldCycle),
                    items: BillingCycle.values
                        .map((b) => DropdownMenuItem(
                            value: b,
                            child: Text(b.localizedLabel(l))))
                        .toList(),
                    onChanged: (v) => _notifier.setBillingCycle(v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sectionHeader(l.sectionCancellation),
            DropdownButtonFormField<CancellationMethod>(
              initialValue: state.cancellationMethod,
              decoration:
                  InputDecoration(labelText: l.fieldCancellationMethod),
              items: CancellationMethod.values
                  .map((m) => DropdownMenuItem(
                      value: m,
                      child: Text(m.localizedLabel(l))))
                  .toList(),
              onChanged: (v) => _notifier.setCancellationMethod(v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noticePeriodCtrl,
              decoration: InputDecoration(
                labelText: l.fieldNoticePeriod,
                hintText: l.fieldNoticePeriodHint,
              ),
              onChanged: _notifier.setNoticePeriod,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cancInstructCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l.fieldCancellationInstructions,
                alignLabelWithHint: true,
              ),
              onChanged: _notifier.setCancellationInstructions,
            ),
            ],
            // Kontaktdaten gehoeren zum Anbieter eines Vertrags — fuer einen
            // Zugang nicht relevant.
            if (!isZugang) ...[
              const SizedBox(height: 24),
              _sectionHeader(l.sectionContact),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    labelText: l.fieldPhone,
                    prefixIcon: const Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText: l.fieldEmail,
                    prefixIcon: const Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _urlCtrl,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                    labelText: l.fieldWebsite,
                    prefixIcon: const Icon(Icons.link_outlined)),
              ),
            ],
            if (!isZugang) ...[
              const SizedBox(height: 24),
              _sectionHeader(l.sectionDuration),
              _datePicker(
                label: l.fieldContractStart,
                date: state.contractStart,
                onPicked: _notifier.setContractStart,
                pickDateLabel: l.pickDate,
              ),
              const SizedBox(height: 12),
              _datePicker(
                label: l.fieldNextRenewal,
                date: state.nextRenewal,
                onPicked: _notifier.setNextRenewal,
                pickDateLabel: l.pickDate,
              ),
            ],
            const SizedBox(height: 24),
            _loginSection(state, l),
            const SizedBox(height: 24),
            _sectionHeader(l.sectionNotes),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l.sectionNotes,
                alignLabelWithHint: true,
                hintText: l.fieldNotesHint,
              ),
              onChanged: _notifier.setNotes,
            ),
            const SizedBox(height: 32),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(state.error!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error)),
              ),
            FilledButton(
              onPressed: state.isSubmitting ? null : _save,
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(isEdit ? l.updateButton : l.saveButton),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _confidenceBanner(ExtractionConfidence confidence, l) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg, icon, message) = switch (confidence) {
      ExtractionConfidence.high => (
          Colors.green.shade50,
          Colors.green.shade800,
          Icons.check_circle_outline,
          l.confidenceHigh,
        ),
      ExtractionConfidence.medium => (
          Colors.amber.shade50,
          Colors.amber.shade900,
          Icons.warning_amber_outlined,
          l.confidenceMedium,
        ),
      ExtractionConfidence.low => (
          scheme.errorContainer,
          scheme.onErrorContainer,
          Icons.error_outline,
          l.confidenceLow,
        ),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child:
                Text(message, style: TextStyle(fontSize: 13, color: fg)),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.close, size: 18, color: fg),
            onPressed: () =>
                setState(() => _extractionConfidence = null),
          ),
        ],
      ),
    );
  }

  Widget _loginSection(AddContractState state, l) {
    final policy =
        ref.watch(heirPasswordPolicyProvider).valueOrNull ??
            HeirPasswordPolicy.none;
    // Bei einem eigenstaendigen Zugang ist das Passwort der Kern des Eintrags —
    // es wird immer angeboten, auch wenn die Erben-Policy "none" ist.
    final isZugang = state.entryType.isZugang;
    final showPasswordFields = policy != HeirPasswordPolicy.none || isZugang;
    final hasExistingPw = state.loginPasswordCt != null;
    final lastVerified = state.loginLastVerifiedAt;
    final isStale = lastVerified != null &&
        DateTime.now().difference(lastVerified).inDays > 180;
    final policyHint = switch (policy) {
      HeirPasswordPolicy.none => l.loginPolicyHintNone,
      HeirPasswordPolicy.komfort => l.loginPolicyHintKomfort,
      HeirPasswordPolicy.maximum => l.loginPolicyHintMaximum,
    };
    final policyHintColor = switch (policy) {
      HeirPasswordPolicy.none => AppColors.textTertiary,
      HeirPasswordPolicy.komfort => AppColors.statusBlue,
      HeirPasswordPolicy.maximum => AppColors.statusGreen,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(l.sectionLogin),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(l.sectionLoginSubtitle,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textTertiary)),
        ),
        // Hinweis: aktuelle Policy + Konsequenz fuer diesen Vertrag.
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: policyHintColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 16, color: policyHintColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(policyHint,
                    style: TextStyle(fontSize: 12, color: policyHintColor)),
              ),
            ],
          ),
        ),
        // Wenn die Policy "none" ist (und es kein Zugang ist), blenden wir die
        // Passwort-Felder aus — dann ist nur das Hint-Feld sichtbar.
        if (showPasswordFields) ...[
          TextFormField(
            controller: _loginUsernameCtrl,
            decoration: InputDecoration(
              labelText: l.fieldLoginUsername,
              prefixIcon: const Icon(Icons.person_outline),
            ),
            onChanged: (v) => _notifier
                .setLoginUsername(v.isEmpty ? null : v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _loginPasswordCtrl,
            obscureText: _passwordObscured,
            decoration: InputDecoration(
              labelText: l.fieldLoginPassword,
              hintText: hasExistingPw
                  ? l.fieldLoginPasswordPlaceholderExisting
                  : null,
              helperText: hasExistingPw
                  ? l.fieldLoginPasswordHintExisting
                  : null,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_passwordObscured
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () =>
                    setState(() => _passwordObscured = !_passwordObscured),
              ),
            ),
            onChanged: (v) {
              if (v.isEmpty) return; // leeres Feld = unveraendert
              _notifier.setLoginPasswordNew(v);
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  lastVerified == null
                      ? l.loginLastVerifiedNever
                      : l.loginLastVerifiedRecent(_formatDate(lastVerified)),
                  style: TextStyle(
                      fontSize: 12,
                      color: isStale
                          ? AppColors.statusAmber
                          : AppColors.textTertiary),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  _notifier.markLoginVerifiedNow();
                },
                icon: const Icon(Icons.check, size: 16),
                label: Text(l.loginConfirmNowButton,
                    style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
          if (isStale)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(l.loginStaleWarning,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.statusAmber)),
            ),
          const SizedBox(height: 12),
        ],
        TextFormField(
          controller: _loginHintCtrl,
          decoration: InputDecoration(
            labelText: l.fieldLoginHint,
            hintText: l.fieldLoginHintHint,
            prefixIcon: const Icon(Icons.note_outlined),
          ),
          onChanged: (v) => _notifier.setLoginHint(v.isEmpty ? null : v),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _datePicker({
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime?> onPicked,
    required String pickDateLabel,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: date != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => onPicked(null),
                )
              : const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(
          date != null
              ? '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}'
              : pickDateLabel,
          style: TextStyle(color: date == null ? Colors.grey : null),
        ),
      ),
    );
  }
}
