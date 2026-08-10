import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pacto/features/onboarding/onboarding_screen.dart';
import 'package:pacto/l10n/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('de'),
      home: child,
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // Regression: "Einführung wiederholen" aus den Einstellungen darf NICHT
  // erneut nach dem Namen fragen.
  testWidgets('Replay-Onboarding zeigt keine Namensseite', (tester) async {
    await tester.pumpWidget(
      _wrap(OnboardingScreen(isReplay: true, onDone: () {})),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
  });

  // Regression: Abschluss im Wiederholungs-Modus muss onDone auslösen
  // (früher No-Op → Nutzer hing fest).
  testWidgets('Replay-Onboarding: letzter Slide schließt via onDone',
      (tester) async {
    var done = false;
    await tester.pumpWidget(
      _wrap(OnboardingScreen(isReplay: true, onDone: () => done = true)),
    );
    await tester.pumpAndSettle();

    // Es gibt genau einen FilledButton (den Weiter-/Abschluss-Button).
    // Drei Info-Slides: 2× weiter, dann schließt der Button.
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(done, isFalse, reason: 'Vor dem letzten Tap noch nicht fertig');

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(done, isTrue);
  });

  // Gegenprobe: Der Erststart-Modus zeigt weiterhin die Namensseite.
  testWidgets('Erststart-Onboarding hat weiterhin eine Namensseite',
      (tester) async {
    await tester.pumpWidget(
      _wrap(OnboardingScreen(onDone: () {})),
    );
    await tester.pumpAndSettle();

    // Durch die 3 Info-Slides zur Namensseite blättern.
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
  });
}
