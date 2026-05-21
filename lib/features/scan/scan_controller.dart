import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'extraction_result.dart';
import 'extraction_service.dart';

enum ScanSource { camera, gallery, file }

class ScanController {
  final ExtractionService _service = ExtractionService();

  Future<File?> pickImage(ScanSource source) async {
    final result = await FilePicker.platform.pickFiles(
      type: source == ScanSource.file ? FileType.any : FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;
    return File(result.files.first.path!);
  }

  Future<ExtractionResult?> scanFile(
      BuildContext context, ScanSource source) async {
    final file = await pickImage(source);
    if (file == null) return null;
    return extractFromFile(file);
  }

  /// Extrahiert Vertragsdaten aus einer bereits vorliegenden Datei
  /// (z.B. ueber die Teilen-Funktion einer anderen App).
  Future<ExtractionResult> extractFromFile(File file) async {
    final isPdf = file.path.toLowerCase().endsWith('.pdf');
    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);
    final mediaType = isPdf ? 'application/pdf' : 'image/jpeg';
    return _service.extractFromBase64Image(base64Image, mediaType);
  }
}

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _ctrl = ScanController();
  bool _loading = false;
  String? _error;

  Future<void> _scan(ScanSource source) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _ctrl.scanFile(context, source);
      if (result != null && mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dokument scannen')),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('KI analysiert Dokument…'),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Wähle eine Quelle',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Die KI extrahiert automatisch Vertragsdetails.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  _button(
                    icon: Icons.photo_library_outlined,
                    label: 'Foto aus Galerie',
                    onTap: () => _scan(ScanSource.gallery),
                  ),
                  const SizedBox(height: 12),
                  _button(
                    icon: Icons.attach_file,
                    label: 'Datei / PDF auswählen',
                    onTap: () => _scan(ScanSource.file),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _button(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
