import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../provider_library/provider_library_screen.dart';
import '../scan/scan_controller.dart';
import 'add_contract_provider.dart';

class AddContractScreen extends ConsumerStatefulWidget {
  final Contract? existing;

  const AddContractScreen({super.key, this.existing});

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
    final state =
        ref.read(addContractProvider(widget.existing));
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
    final result = await Navigator.of(context)
        .push<dynamic>(MaterialPageRoute(builder: (_) => const ScanScreen()));
    if (result == null) return;
    _notifier.prefillFromTemplate(
      _extractionResultAsTemplate(result),
    );
    final state = ref.read(addContractProvider(widget.existing));
    _nameCtrl.text = state.name;
    _providerCtrl.text = state.provider;
    _costCtrl.text = state.monthlyCost.toStringAsFixed(2);
    _cancInstructCtrl.text = state.cancellationInstructions;
    _noticePeriodCtrl.text = state.noticePeriod;
    _phoneCtrl.text = state.contactPhone ?? '';
    _emailCtrl.text = state.contactEmail ?? '';
    _urlCtrl.text = state.contactUrl ?? '';
    _notesCtrl.text = state.notes;
    setState(() {});
  }

  dynamic _extractionResultAsTemplate(dynamic result) => result;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _syncControllersToState();
    final state = ref.read(addContractProvider(widget.existing));
    _notifier.setMonthlyCostFromInput(_costCtrl.text, state.billingCycle);
    final ok = await _notifier.save();
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addContractProvider(widget.existing));
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Vertrag bearbeiten' : 'Vertrag hinzufügen'),
        actions: [
          if (!isEdit) ...[
            IconButton(
              icon: const Icon(Icons.list_alt_outlined),
              tooltip: 'Aus Bibliothek',
              onPressed: _openLibrary,
            ),
            IconButton(
              icon: const Icon(Icons.document_scanner_outlined),
              tooltip: 'Scannen',
              onPressed: _openScan,
            ),
          ],
          TextButton(
            onPressed: state.isSubmitting ? null : _save,
            child: const Text('Speichern'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionHeader('Basisdaten'),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Name *'),
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Name ist erforderlich' : null,
              onChanged: _notifier.setName,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _providerCtrl,
              decoration: const InputDecoration(labelText: 'Anbieter *'),
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Anbieter ist erforderlich' : null,
              onChanged: _notifier.setProvider,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ContractCategory>(
              value: state.category,
              decoration: const InputDecoration(labelText: 'Kategorie'),
              items: ContractCategory.values
                  .map((c) => DropdownMenuItem(
                      value: c, child: Text(c.label)))
                  .toList(),
              onChanged: (v) => _notifier.setCategory(v!),
            ),
            const SizedBox(height: 24),
            _sectionHeader('Kosten'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _costCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Betrag (€)',
                      suffixText: '€',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<BillingCycle>(
                    value: state.billingCycle,
                    decoration:
                        const InputDecoration(labelText: 'Zyklus'),
                    items: BillingCycle.values
                        .map((b) => DropdownMenuItem(
                            value: b, child: Text(b.label)))
                        .toList(),
                    onChanged: (v) => _notifier.setBillingCycle(v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sectionHeader('Kündigung'),
            DropdownButtonFormField<CancellationMethod>(
              value: state.cancellationMethod,
              decoration: const InputDecoration(labelText: 'Methode'),
              items: CancellationMethod.values
                  .map((m) => DropdownMenuItem(
                      value: m, child: Text(m.label)))
                  .toList(),
              onChanged: (v) => _notifier.setCancellationMethod(v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noticePeriodCtrl,
              decoration: const InputDecoration(
                labelText: 'Kündigungsfrist',
                hintText: 'z.B. "3 Monate zum Quartalsende"',
              ),
              onChanged: _notifier.setNoticePeriod,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cancInstructCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Kündigungsanleitung',
                alignLabelWithHint: true,
              ),
              onChanged: _notifier.setCancellationInstructions,
            ),
            const SizedBox(height: 24),
            _sectionHeader('Kontakt'),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                  labelText: 'Telefon',
                  prefixIcon: Icon(Icons.phone_outlined)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  labelText: 'E-Mail',
                  prefixIcon: Icon(Icons.email_outlined)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _urlCtrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                  labelText: 'Website',
                  prefixIcon: Icon(Icons.link_outlined)),
            ),
            const SizedBox(height: 24),
            _sectionHeader('Laufzeit'),
            _datePicker(
              label: 'Vertragsbeginn',
              date: state.contractStart,
              onPicked: _notifier.setContractStart,
            ),
            const SizedBox(height: 12),
            _datePicker(
              label: 'Nächste Verlängerung',
              date: state.nextRenewal,
              onPicked: _notifier.setNextRenewal,
            ),
            const SizedBox(height: 24),
            _sectionHeader('Notizen'),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notizen',
                alignLabelWithHint: true,
                hintText: 'Besonderheiten, Sonderkündigungsrecht…',
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
                  : Text(isEdit ? 'Aktualisieren' : 'Speichern'),
            ),
            const SizedBox(height: 32),
          ],
        ),
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
              : 'Datum wählen',
          style: TextStyle(
              color: date == null ? Colors.grey : null),
        ),
      ),
    );
  }
}
