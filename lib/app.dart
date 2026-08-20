import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'data/providers/database_provider.dart';
import 'data/sync/vault_service.dart';
import 'features/home/home_shell.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/scan/share_import_screen.dart';
import 'features/security/app_lock_service.dart';
import 'features/security/lock_screen.dart';
import 'l10n/app_localizations.dart';
import 'shared/locale_provider.dart';
import 'shared/theme/app_theme.dart';
import 'shared/widgets/app_background.dart';

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
      builder: (context, child) =>
          AppBackground(child: child ?? const SizedBox.shrink()),
      home: const _Root(),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> with WidgetsBindingObserver {
  bool? _onboardingDone;
  // App-Sperre: null = noch nicht geladen.
  bool? _lockEnabled;
  bool _unlocked = false;
  final AppLockService _lock = AppLockService();
  StreamSubscription<List<SharedMediaFile>>? _shareSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    isOnboardingDone().then((v) {
      if (mounted) setState(() => _onboardingDone = v);
    });
    _lock.isEnabled().then((v) {
      if (mounted) setState(() => _lockEnabled = v);
    });
    _initShareHandler();
    // Beim ersten Start ein Lebenszeichen senden, damit die confirmed_at
    // auf dem Server stets aktuell ist und die Vorwarnung nicht
    // versehentlich feuert.
    unawaited(VaultService.heartbeat());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shareSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(VaultService.heartbeat());
      // Sperr-Status neu laden (kann in den Einstellungen geaendert worden
      // sein, waehrend die App im Hintergrund war).
      _lock.isEnabled().then((v) {
        if (mounted) setState(() => _lockEnabled = v);
      });
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      // Beim Verlassen wieder sperren.
      if (_unlocked) setState(() => _unlocked = false);
      // Defense-in-Depth: den im Speicher gehaltenen AES-Key leeren. Er liegt
      // geraetegebunden in secure storage und wird bei Bedarf neu geladen.
      ProviderScope.containerOf(context, listen: false)
          .read(cryptoServiceProvider)
          .clearCachedKey();
    }
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
    if (_onboardingDone == null || _lockEnabled == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_onboardingDone == false) {
      return OnboardingScreen(
        onDone: () => setState(() => _onboardingDone = true),
      );
    }
    // Sperre kommt NACH dem Onboarding und VOR der App.
    if (_lockEnabled == true && !_unlocked) {
      return LockScreen(onUnlocked: () => setState(() => _unlocked = true));
    }
    return const HomeShell();
  }
}
