import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/l10n/l10n_extension.dart';
import '../account/login_screen.dart';

const _keyOnboardingDone = 'pacto.onboarding.done';
const _keyUserName = 'pacto.user.name';

Future<bool> isOnboardingDone() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_keyOnboardingDone) ?? false;
}

Future<void> markOnboardingDone(bool done) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_keyOnboardingDone, done);
}

Future<String?> getUserName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_keyUserName);
}

Future<void> setUserName(String? name) async {
  final prefs = await SharedPreferences.getInstance();
  if (name == null || name.trim().isEmpty) {
    await prefs.remove(_keyUserName);
  } else {
    await prefs.setString(_keyUserName, name.trim());
  }
}

class _Slide {
  final IconData icon;
  final String title;
  final String body;
  const _Slide(this.icon, this.title, this.body);
}

List<_Slide> _buildSlides(AppLocalizations l) => [
      _Slide(Icons.receipt_long_outlined, l.onboarding1Title, l.onboarding1Body),
      _Slide(Icons.document_scanner_outlined, l.onboarding2Title, l.onboarding2Body),
      _Slide(Icons.family_restroom, l.onboarding3Title, l.onboarding3Body),
    ];

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;

  /// Wiederholungs-Modus (aus den Einstellungen aufgerufen): zeigt nur die
  /// Info-Slides, überspringt die Namens-/Konto-Seite und lässt den
  /// vorhandenen Namen unangetastet.
  final bool isReplay;

  const OnboardingScreen({
    super.key,
    required this.onDone,
    this.isReplay = false,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  final _nameCtrl = TextEditingController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish({String? name}) async {
    await setUserName(name);
    await markOnboardingDone(true);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final slides = _buildSlides(l);
    // Im Wiederholungs-Modus entfällt die Namens-/Konto-Seite.
    final totalPages = widget.isReplay ? slides.length : slides.length + 1;
    final isNamePage = !widget.isReplay && _page == slides.length;
    final isLastSlide = _page == slides.length - 1;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.isReplay ? widget.onDone : () => _finish(),
                child: Text(l.onboardingSkip),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: totalPages,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (ctx, i) {
                  if (i == slides.length) return _namePage(l, scheme);
                  final s = slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(s.icon, size: 96, color: scheme.primary),
                        const SizedBox(height: 32),
                        Text(
                          s.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          s.body,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              color: scheme.onSurface.withValues(alpha: 0.6),
                              height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalPages, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: active ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: active ? scheme.primary : scheme.outline,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            if (!isNamePage)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: (widget.isReplay && isLastSlide)
                        ? widget.onDone
                        : () => _controller.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            ),
                    child: Text((widget.isReplay && isLastSlide)
                        ? l.onboardingStart
                        : l.onboardingNext),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _namePage(AppLocalizations l, ColorScheme scheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.waving_hand_outlined, size: 96, color: scheme.primary),
          const SizedBox(height: 32),
          Text(
            l.onboardingNameTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l.onboardingNameBody,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15,
                color: scheme.onSurface.withValues(alpha: 0.6),
                height: 1.5),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: l.onboardingNameHint,
              prefixIcon: const Icon(Icons.person_outline),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (v) => _finish(name: v),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _finish(name: _nameCtrl.text),
              child: Text(l.onboardingStart),
            ),
          ),
          TextButton(
            onPressed: () async {
              final restored = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) =>
                      const LoginScreen(autoRestoreOnSuccess: true),
                ),
              );
              if (restored == true) {
                _finish(name: _nameCtrl.text.isNotEmpty ? _nameCtrl.text : null);
              }
            },
            child: Text(l.onboardingHaveAccountLink),
          ),
          TextButton(
            onPressed: () => _finish(),
            child: Text(l.onboardingNameSkip),
          ),
        ],
      ),
    );
  }
}
