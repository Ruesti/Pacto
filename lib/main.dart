import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'app.dart';
import 'config/supabase_config.dart';
import 'data/sync/cloud_sync_service.dart';
import 'features/scan/extraction_service.dart';

const _heartbeatTask = 'pacto-heartbeat';

/// Hintergrund-Einstiegspunkt fuer workmanager — laeuft in einem eigenen Isolate.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      await CloudSyncService.sendHeartbeat();
      return true;
    } catch (_) {
      return false;
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // KI-Scan + Cloud-Sync nutzen das fest eingebaute Pacto-Supabase-Projekt —
  // keine Einrichtung durch den Nutzer noetig.
  ExtractionService.configure(
    edgeFunctionUrl: SupabaseConfig.extractFunctionUrl,
    anonKey: SupabaseConfig.anonKey,
  );

  // Hintergrund-Heartbeat fuer den Inaktivitaets-Tresor (nur Mobile).
  if (Platform.isAndroid || Platform.isIOS) {
    try {
      await Workmanager().initialize(callbackDispatcher);
      await Workmanager().registerPeriodicTask(
        _heartbeatTask,
        _heartbeatTask,
        frequency: const Duration(days: 30),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
        constraints: Constraints(networkType: NetworkType.connected),
      );
    } catch (_) {
      // Heartbeat ist optional — die App startet auch ohne.
    }
  }

  runApp(const ProviderScope(child: PactoApp()));
}
