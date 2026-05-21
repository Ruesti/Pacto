import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'features/settings/scan_config_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await applyStoredScanConfig();
  runApp(const ProviderScope(child: PactoApp()));
}
