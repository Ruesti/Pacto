import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/scan/share_import_screen.dart';
import 'l10n/app_localizations.dart';
import 'shared/locale_provider.dart';
import 'shared/theme/app_theme.dart';

class PactoApp extends ConsumerWidget {
  const PactoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp(
      title: 'Pacto',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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

  void _initShareHandler() {
    if (!(Platform.isAndroid || Platform.isIOS)) return;
    _shareSub = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen(_handleShared, onError: (_) {});
    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      _handleShared(files);
      ReceiveSharingIntent.instance.reset();
    });
  }

  void _handleShared(List<SharedMediaFile> files) {
    if (!mounted || files.isEmpty) return;

    SharedMediaFile? urlFile;
    for (final f in files) {
      if (f.type == SharedMediaType.url) {
        urlFile = f;
        break;
      }
      if (f.type == SharedMediaType.text &&
          (f.path.startsWith('http://') || f.path.startsWith('https://'))) {
        urlFile = f;
        break;
      }
    }
    if (urlFile != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ShareImportScreen(url: urlFile!.path),
      ));
      return;
    }

    SharedMediaFile? fileShare;
    for (final f in files) {
      if (f.type == SharedMediaType.image || f.type == SharedMediaType.file) {
        fileShare = f;
        break;
      }
    }
    if (fileShare == null) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ShareImportScreen(filePath: fileShare!.path),
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
