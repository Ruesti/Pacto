import 'dart:io';
import 'package:flutter/material.dart';
import '../../shared/l10n/l10n_extension.dart';
import '../add_contract/add_contract_screen.dart';
import 'scan_controller.dart';

class ShareImportScreen extends StatefulWidget {
  final String? filePath;
  final String? url;

  const ShareImportScreen({super.key, this.filePath, this.url})
      : assert(filePath != null || url != null,
            'Either filePath or url must be provided');

  @override
  State<ShareImportScreen> createState() => _ShareImportScreenState();
}

class _ShareImportScreenState extends State<ShareImportScreen> {
  final _controller = ScanController();
  String? _error;

  bool get _isUrl => widget.url != null;

  @override
  void initState() {
    super.initState();
    _process();
  }

  Future<void> _process() async {
    setState(() => _error = null);
    try {
      final result = _isUrl
          ? await _controller.extractFromUrl(widget.url!)
          : await _controller.extractFromFile(File(widget.filePath!));
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
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
          title: Text(
              _isUrl ? l.shareImportTitleUrl : l.shareImportTitleFile)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _error == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(_isUrl
                        ? l.shareImportLoadingUrl
                        : l.shareImportLoadingFile),
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
                      label: Text(l.retryButton),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const AddContractScreen())),
                      child: Text(l.createManually),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
