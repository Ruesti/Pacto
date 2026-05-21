import 'dart:io';
import 'package:flutter/material.dart';
import '../add_contract/add_contract_screen.dart';
import 'scan_controller.dart';

/// Verarbeitet eine aus einer anderen App geteilte Datei: extrahiert die
/// Vertragsdaten per KI und oeffnet danach das vorausgefuellte Formular.
class ShareImportScreen extends StatefulWidget {
  final String filePath;
  const ShareImportScreen({super.key, required this.filePath});

  @override
  State<ShareImportScreen> createState() => _ShareImportScreenState();
}

class _ShareImportScreenState extends State<ShareImportScreen> {
  final _controller = ScanController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _process();
  }

  Future<void> _process() async {
    setState(() => _error = null);
    try {
      final result =
          await _controller.extractFromFile(File(widget.filePath));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => AddContractScreen(initialExtraction: result),
      ));
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Geteiltes Dokument')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _error == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('KI analysiert das geteilte Dokument…'),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: 16),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _process,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Erneut versuchen'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const AddContractScreen())),
                      child: const Text('Manuell anlegen'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
