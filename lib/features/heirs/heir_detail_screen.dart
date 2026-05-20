import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/providers/database_provider.dart';
import 'share_export_service.dart';

class HeirDetailScreen extends ConsumerStatefulWidget {
  final Heir? existing;

  const HeirDetailScreen({super.key, this.existing});

  @override
  ConsumerState<HeirDetailScreen> createState() => _HeirDetailScreenState();
}

class _HeirDetailScreenState extends ConsumerState<HeirDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  final _pinCtrl = TextEditingController();
  late HeirAccess _access;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _emailCtrl = TextEditingController(text: widget.existing?.email ?? '');
    _access = widget.existing?.accessLevel ?? HeirAccess.nurListe;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final dao = ref.read(heirsDaoProvider);
      final pinHash = _pinCtrl.text.isNotEmpty
          ? ShareExportService.hashPin(_pinCtrl.text)
          : (widget.existing?.pinHash ?? ShareExportService.hashPin('000000'));

      if (widget.existing != null) {
        await dao.updateHeir(HeirsCompanion(
          id: Value(widget.existing!.id),
          name: Value(_nameCtrl.text.trim()),
          email: Value(_emailCtrl.text.trim()),
          pinHash: Value(pinHash),
          accessLevel: Value(_access),
        ));
      } else {
        await dao.insertHeir(HeirsCompanion.insert(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          pinHash: pinHash,
          accessLevel: Value(_access),
        ));
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Erbe bearbeiten' : 'Erbe hinzufügen'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Speichern'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'Name', prefixIcon: Icon(Icons.person_outline)),
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Name ist erforderlich' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  labelText: 'E-Mail', prefixIcon: Icon(Icons.email_outlined)),
              validator: (v) =>
                  v?.isEmpty ?? true ? 'E-Mail ist erforderlich' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pinCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 8,
              decoration: InputDecoration(
                labelText: isEdit ? 'Neuen PIN setzen (optional)' : 'PIN setzen',
                prefixIcon: const Icon(Icons.lock_outline),
                helperText: 'Mind. 6 Ziffern',
              ),
              validator: (v) {
                if (!isEdit && (v == null || v.length < 6)) {
                  return 'PIN muss mind. 6 Ziffern haben';
                }
                if (v != null && v.isNotEmpty && v.length < 6) {
                  return 'PIN muss mind. 6 Ziffern haben';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<HeirAccess>(
              value: _access,
              decoration: const InputDecoration(
                  labelText: 'Zugangsstufe',
                  prefixIcon: Icon(Icons.visibility_outlined)),
              items: HeirAccess.values
                  .map((a) => DropdownMenuItem(
                      value: a, child: Text(a.label)))
                  .toList(),
              onChanged: (v) => setState(() => _access = v!),
            ),
            const SizedBox(height: 24),
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Zugangsstufen erklärt:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    for (final a in HeirAccess.values)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• ${a.label}',
                            style: const TextStyle(fontSize: 13)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
