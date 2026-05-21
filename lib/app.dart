import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/scan/share_import_screen.dart';
import 'shared/theme/app_theme.dart';

class PactoApp extends ConsumerWidget {
  const PactoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Pacto',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const _Root(),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  bool? _onboardingDone;
  StreamSubscription<List<SharedMediaFile>>? _shareSub;

  @override
  void initState() {
    super.initState();
    isOnboardingDone().then((v) {
      if (mounted) setState(() => _onboardingDone = v);
    });
    _initShareHandler();
  }

  @override
  void dispose() {
    _shareSub?.cancel();
    super.dispose();
  }

  // Empfaengt Bilder/PDFs, die aus anderen Apps an Pacto geteilt werden.
  void _initShareHandler() {
    if (!(Platform.isAndroid || Platform.isIOS)) return;
    // Teilen waehrend die App laeuft.
    _shareSub = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen(_handleShared, onError: (_) {});
    // Teilen, das die App gestartet hat (Kaltstart).
    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      _handleShared(files);
      ReceiveSharingIntent.instance.reset();
    });
  }

  void _handleShared(List<SharedMediaFile> files) {
    if (!mounted || files.isEmpty) return;
    final shared = files.firstWhere(
      (f) =>
          f.type == SharedMediaType.image || f.type == SharedMediaType.file,
      orElse: () => files.first,
    );
    if (shared.type != SharedMediaType.image &&
        shared.type != SharedMediaType.file) {
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ShareImportScreen(filePath: shared.path),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingDone == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_onboardingDone == false) {
      return OnboardingScreen(
        onDone: () => setState(() => _onboardingDone = true),
      );
    }
    return const DashboardScreen();
  }
}
