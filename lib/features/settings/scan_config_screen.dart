import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../scan/extraction_service.dart';

const _keyUrl = 'pacto.scan.edge_url';
const _keyAnonKey = 'pacto.scan.anon_key';

Future<void> applyStoredScanConfig() async {
  final prefs = await SharedPreferences.getInstance();
  final url = prefs.getString(_keyUrl) ?? '';
  final key = prefs.getString(_keyAnonKey) ?? '';
  if (url.isNotEmpty && key.isNotEmpty) {
    ExtractionService.configure(edgeFunctionUrl: url, anonKey: key);
  }
}

class ScanConfigScreen extends StatefulWidget {
  const ScanConfigScreen({super.key});

  @override
  State<ScanConfigScreen> createState() => _ScanConfigScreenState();
}

class _ScanConfigScreenState extends State<ScanConfigScreen> {
  final _urlCtrl = TextEditingController();
  final _keyCtrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _keyCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _urlCtrl.text = prefs.getString(_keyUrl) ?? '';
    _keyCtrl.text = prefs.getString(_keyAnonKey) ?? '';
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    final url = _urlCtrl.text.trim();
    final key = _keyCtrl.text.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUrl, url);
    await prefs.setString(_keyAnonKey, key);
    if (url.isNotEmpty && key.isNotEmpty) {
      ExtractionService.configure(edgeFunctionUrl: url, anonKey: key);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('KI-Scan Konfiguration gespeichert')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KI-Scan Konfiguration')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Die KI-Extraktion läuft über eine Supabase Edge Function. '
                  'Der Anthropic-Schlüssel liegt serverseitig in deinem Supabase-Projekt. '
                  'Hier hinterlegst du nur die URL der Edge Function und deinen Anon Key.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _urlCtrl,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Edge Function URL',
                    hintText:
                        'https://<projekt>.supabase.co/functions/v1/extract-contract',
                    prefixIcon: Icon(Icons.link_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _keyCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Supabase Anon Key',
                    prefixIcon: Icon(Icons.key_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Speichern'),
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Setup-Anleitung',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                          '1. Supabase-Projekt anlegen (kostenlos auf supabase.com).\n'
                          '2. Edge Function deployen:\n'
                          '   supabase functions deploy extract-contract\n'
                          '3. ANTHROPIC_API_KEY als Supabase-Secret hinterlegen.\n'
                          '4. URL und Anon Key aus dem Supabase-Dashboard hier eintragen.',
                          style: TextStyle(fontSize: 13, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
