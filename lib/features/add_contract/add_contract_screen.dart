import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/providers/database_provider.dart';
import '../../shared/l10n/enum_labels.dart';
import '../../shared/l10n/l10n_extension.dart';
import '../premium/premium_service.dart';
import '../provider_library/provider_library_screen.dart';
import '../scan/extraction_result.dart';
import '../scan/scan_controller.dart';
import '../scan/web_search_screen.dart';
import 'add_contract_provider.dart';

class AddContractScreen extends ConsumerStatefulWidget {
  final Contract? existing;
  final ExtractionResult? initialExtraction;

  const AddContractScreen({super.key, this.existing, this.initialExtraction});

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
  final _formKey = GlobalKey<FormState>();
  ExtractionConfidence? _extractionConfidence;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _providerCtrl = TextEditingController(text: e?.provider ?? '');
    _costCtrl = TextEditingController(
        text: e != null ? e.monthlyCost.toStringAsFixed(2) : '');
    _cancInstructCtrl =
        TextEditingController(text: e?.cancellationInstructions ?? '');
    _noticePeriodCtrl = TextEditingController(text: e?.noticePeriod ?? '');
    _phoneCtrl = TextEditingController(text: e?.contactPhone ?? '');
    _emailCtrl = TextEditingController(text: e?.contactEmail ?? '');
    _urlCtrl = TextEditingController(text: e?.contactUrl ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');

    if (widget.initialExtraction != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _applyExtractionResult(widget.initialExtraction!);
      });
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _providerCtrl, _costCtrl, _cancInstructCtrl,
      _noticePeriodCtrl, _phoneCtrl, _emailCtrl, _urlCtrl, _notesCtrl
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
  }

  Future<void> _openLibrary() async {
    final template = await Navigator.of(context).push<dynamic>(
        MaterialPageRoute(builder: (_) => const ProviderLibraryScreen()));
    if (template == null) return;
    _notifier.prefillFromTemplate(template);
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
    _costCtrl.text =
        state.monthlyCost > 0 ? state.monthlyCost.toStringAsFixed(2) : '';
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
    if (ref.read(premiumProvider)) return true;
    final count = (await ref.read(contractsDaoProvider).getAll()).length;
    if (count < freeTierLimit) return true;
    if (!mounted) return false;
    final unlocked = await showPurchaseDialog(context);
    if (unlocked) {
      await ref.read(premiumProvider.notifier).setPurchased(true);
    }
    return unlocked;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!await _passesFreemiumGate()) return;
    _syncControllersToState();
    final state = ref.read(addContractProvider(widget.existing));
    _notifier.setMonthlyCostFromInput(_costCtrl.text, state.billingCycle);
    final ok = await _notifier.save();
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final state = ref.watch(addContractProvider(widget.existing));
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? l.editContractTitle : l.addContractTitle),
        actions: [
          if (!isEdit) ...[
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
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                  labelText: '${l.fieldName} *'),
              validator: (v) =>
                  v?.isEmpty ?? true ? l.validationNameRequired : null,
              onChanged: _notifier.setName,
            ),
            const SizedBox(height: 12),
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
