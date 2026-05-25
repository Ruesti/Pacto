import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../shared/l10n/l10n_extension.dart';
import '../add_contract/add_contract_screen.dart';
import 'scan_controller.dart';

bool get _webViewSupported =>
    Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

class WebSearchScreen extends StatefulWidget {
  final String? initialQuery;

  const WebSearchScreen({super.key, this.initialQuery});

  @override
  State<WebSearchScreen> createState() => _WebSearchScreenState();
}

class _WebSearchScreenState extends State<WebSearchScreen> {
  late final WebViewController _webCtrl;
  late final TextEditingController _barCtrl;
  bool _loading = true;
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    if (!_webViewSupported) return;
    final query = widget.initialQuery?.trim() ?? '';
    final startUrl = _toUrl(query.isEmpty ? '' : '$query Abo Vertrag');
    _currentUrl = startUrl;
    _barCtrl = TextEditingController(text: startUrl);

    _webCtrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) => setState(() {
          _loading = true;
          _currentUrl = url;
          _barCtrl.text = url;
        }),
        onPageFinished: (_) => setState(() => _loading = false),
      ))
      ..loadRequest(Uri.parse(startUrl));
  }

  @override
  void dispose() {
    if (_webViewSupported) _barCtrl.dispose();
    super.dispose();
  }

  String _toUrl(String input) {
    final trimmed = input.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.isEmpty) return 'https://www.google.de';
    return 'https://www.google.de/search?q=${Uri.encodeComponent(trimmed)}';
  }

  void _navigate(String input) =>
      _webCtrl.loadRequest(Uri.parse(_toUrl(input)));

  Future<void> _importCurrentPage() async {
    final url = (await _webCtrl.currentUrl()) ?? _currentUrl;
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _UrlProcessingScreen(url: url),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (!_webViewSupported) {
      return Scaffold(
        appBar: AppBar(title: Text(l.webSearchHint)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.desktop_access_disabled_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                const SizedBox(height: 16),
                Text(
                  l.webSearchUnsupportedPlatform,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (_) => const AddContractScreen())),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l.createManually),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _barCtrl,
          decoration: InputDecoration(
            hintText: l.webSearchHint,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            isDense: true,
          ),
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.go,
          onSubmitted: _navigate,
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _navigate(_barCtrl.text),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webCtrl),
          if (_loading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _importCurrentPage,
        icon: const Icon(Icons.download_outlined),
        label: Text(l.webSearchImportButton),
        tooltip: l.webSearchImportTooltip,
      ),
    );
  }
}

class _UrlProcessingScreen extends StatefulWidget {
  final String url;

  const _UrlProcessingScreen({required this.url});

  @override
  State<_UrlProcessingScreen> createState() => _UrlProcessingScreenState();
}

class _UrlProcessingScreenState extends State<_UrlProcessingScreen> {
  final _ctrl = ScanController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _process();
  }

  Future<void> _process() async {
    setState(() => _error = null);
    try {
      final result = await _ctrl.extractFromUrl(widget.url);
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
      appBar: AppBar(title: Text(l.urlProcessingTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _error == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l.urlProcessingLoading),
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
