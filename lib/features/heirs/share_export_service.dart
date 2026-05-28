import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/database/database.dart';
import '../../data/providers/heir_password_policy_provider.dart';
import '../../data/sync/crypto_service.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../shared/utils/date_formatter.dart';

class ShareExportService {
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  static bool verifyPin(String pin, String hash) {
    return hashPin(pin) == hash;
  }

  static Future<File> exportToPdfText(
      List<Contract> contracts, String ownerName) async {
    final buffer = StringBuffer();
    buffer.writeln('PACTO – VERTRAGSÜBERSICHT');
    buffer.writeln('Erstellt: ${formatDate(DateTime.now())}');
    buffer.writeln('Inhaber: $ownerName');
    buffer.writeln('Vertraulich – Nur für Hinterbliebene');
    buffer.writeln('=' * 60);
    buffer.writeln();

    final total = contracts.fold(0.0, (s, c) => s + c.monthlyCost);
    buffer.writeln('Gesamtkosten: ${formatMonthlyCost(total)}');
    buffer.writeln('Anzahl Verträge: ${contracts.length}');
    buffer.writeln();
    buffer.writeln('=' * 60);
    buffer.writeln();

    for (final c in contracts) {
      buffer.writeln('── ${c.name} ──');
      buffer.writeln('Anbieter:     ${c.provider}');
      buffer.writeln('Kategorie:    ${c.category.label}');
      buffer.writeln('Kosten:       ${formatMonthlyCost(c.monthlyCost)}');
      buffer.writeln('Kündigung:    ${c.cancellationMethod.label}');
      if (c.noticePeriod.isNotEmpty) {
        buffer.writeln('Frist:        ${c.noticePeriod}');
      }
      if (c.nextRenewal != null) {
        buffer.writeln('Verlängerung: ${formatDate(c.nextRenewal)}');
      }
      if (c.contactPhone != null) {
        buffer.writeln('Telefon:      ${c.contactPhone}');
      }
      if (c.contactEmail != null) {
        buffer.writeln('E-Mail:       ${c.contactEmail}');
      }
      if (c.contactUrl != null) {
        buffer.writeln('Website:      ${c.contactUrl}');
      }
      if (c.cancellationInstructions.isNotEmpty) {
        buffer.writeln('Anleitung:');
        buffer.writeln(c.cancellationInstructions);
      }
      if (c.notes.isNotEmpty) {
        buffer.writeln('Notizen:      ${c.notes}');
      }
      buffer.writeln();
    }

    buffer.writeln('Erstellt mit Pacto – softbrewstudio.com');

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/pacto_vertraege_${DateTime.now().millisecondsSinceEpoch}.txt');
    await file.writeAsString(buffer.toString());
    return file;
  }

  static String generateQrContent(List<Contract> contracts) {
    final data = contracts.map((c) => {
      'name': c.name,
      'provider': c.provider,
      'cost': c.monthlyCost,
      'cancel': c.cancellationMethod.name,
      'instructions': c.cancellationInstructions,
    }).toList();
    return jsonEncode({'pacto': '1.0', 'contracts': data});
  }

  /// Erzeugt den Text einer Erben-Mail / -Exports unter Beruecksichtigung der
  /// gewaehlten [HeirPasswordPolicy].
  ///
  /// `none`     → kein Username/Passwort, nur das `loginHint`-Feld pro Vertrag.
  /// `komfort`  → Username + Klartext-Passwort (lokal mit App-Key
  ///              entschluesselt). Geeignet fuer die manuell vom User
  ///              ausgeloeste Weitergabe oder den server-seitigen Versand
  ///              in der Komfort-Stufe.
  /// `maximum`  → Username + per Erben-PIN re-encrypteter Cipher-Envelope.
  ///              `heirPin` ist Pflicht. Server kennt den PIN nie.
  ///
  /// Wirft `ArgumentError`, wenn `policy == maximum` ohne `heirPin` aufgerufen
  /// wird.
  static Future<String> buildHeirExportText({
    required List<Contract> contracts,
    required String ownerName,
    required Heir heir,
    required HeirPasswordPolicy policy,
    required CryptoService crypto,
    String? heirPin,
  }) async {
    if (policy == HeirPasswordPolicy.maximum && (heirPin?.isEmpty ?? true)) {
      throw ArgumentError(
          'Maximum-Modus benoetigt den Erben-PIN zum Verschluesseln.');
    }

    final buffer = StringBuffer();
    buffer.writeln('PACTO – VERTRAGSÜBERSICHT FÜR ${heir.name.toUpperCase()}');
    buffer.writeln('Erstellt: ${formatDate(DateTime.now())}');
    buffer.writeln('Inhaber: $ownerName');
    buffer.writeln('Vertraulich – Nur für Hinterbliebene');
    buffer.writeln('=' * 60);
    buffer.writeln();

    // Policy-Hinweis am Anfang, damit der Erbe versteht was er bekommen hat
    // und was er ggf. tun muss.
    switch (policy) {
      case HeirPasswordPolicy.none:
        buffer.writeln(
            'Hinweis: $ownerName hat in Pacto bewusst keine Passwoerter '
            'gespeichert. Wo Login-Daten benoetigt werden, findest du den '
            'Hinweis "Login-Hinweis" unter dem jeweiligen Vertrag.');
        break;
      case HeirPasswordPolicy.komfort:
        buffer.writeln(
            'Hinweis: Login-Daten stehen unten direkt im Klartext. Bitte '
            'vertraulich behandeln.');
        break;
      case HeirPasswordPolicy.maximum:
        buffer.writeln(
            'Hinweis: Login-Passwoerter sind verschluesselt. Du benoetigst '
            'deinen vorab erhaltenen Pacto-PIN, um sie zu entschluesseln. '
            'Oeffne die Pacto-App und gib unter "Erbendaten entsperren" '
            'deinen PIN ein.');
        break;
    }
    buffer.writeln();
    buffer.writeln('=' * 60);
    buffer.writeln();

    final total = contracts.fold(0.0, (s, c) => s + c.monthlyCost);
    buffer.writeln('Gesamtkosten: ${formatMonthlyCost(total)}');
    buffer.writeln('Anzahl Verträge: ${contracts.length}');
    buffer.writeln();
    buffer.writeln('=' * 60);
    buffer.writeln();

    for (final c in contracts) {
      buffer.writeln('── ${c.name} ──');
      buffer.writeln('Anbieter:     ${c.provider}');
      buffer.writeln('Kategorie:    ${c.category.label}');
      buffer.writeln('Kosten:       ${formatMonthlyCost(c.monthlyCost)}');
      buffer.writeln('Kündigung:    ${c.cancellationMethod.label}');
      if (c.noticePeriod.isNotEmpty) {
        buffer.writeln('Frist:        ${c.noticePeriod}');
      }
      if (c.nextRenewal != null) {
        buffer.writeln('Verlängerung: ${formatDate(c.nextRenewal)}');
      }
      if (c.contactPhone != null) {
        buffer.writeln('Telefon:      ${c.contactPhone}');
      }
      if (c.contactEmail != null) {
        buffer.writeln('E-Mail:       ${c.contactEmail}');
      }
      if (c.contactUrl != null) {
        buffer.writeln('Website:      ${c.contactUrl}');
      }

      // ─── Login-Block je nach Policy ───
      final hasUsername = (c.loginUsername ?? '').isNotEmpty;
      final hasPassword = c.loginPasswordCt != null;
      final hasHint = (c.loginHint ?? '').isNotEmpty;
      if (hasUsername || hasPassword || hasHint) {
        buffer.writeln('Login:');
        if (hasUsername) {
          buffer.writeln('  Benutzer:   ${c.loginUsername}');
        }
        if (hasPassword) {
          switch (policy) {
            case HeirPasswordPolicy.none:
              // explizit: Passwort wird in dieser Stufe ignoriert.
              break;
            case HeirPasswordPolicy.komfort:
              try {
                final plain =
                    await crypto.decryptString(c.loginPasswordCt!);
                buffer.writeln('  Passwort:   $plain');
              } catch (_) {
                buffer.writeln(
                    '  Passwort:   (gespeichert, konnte aber nicht '
                    'entschluesselt werden — bitte beim Inhaber pruefen)');
              }
              break;
            case HeirPasswordPolicy.maximum:
              try {
                final plain =
                    await crypto.decryptString(c.loginPasswordCt!);
                final reCt = await crypto.encryptWithPin(plain, heirPin!);
                buffer.writeln(
                    '  Passwort:   [verschluesselt, PIN benoetigt]');
                buffer.writeln('  Cipher:     $reCt');
              } catch (_) {
                buffer.writeln('  Passwort:   (Fehler bei Verschluesselung)');
              }
              break;
          }
        }
        if (hasHint) {
          buffer.writeln('  Hinweis:    ${c.loginHint}');
        }
        if (c.loginLastVerifiedAt != null) {
          buffer.writeln(
              '  Zuletzt bestaetigt: ${formatDate(c.loginLastVerifiedAt)}');
        }
      }

      if (c.cancellationInstructions.isNotEmpty) {
        buffer.writeln('Anleitung:');
        buffer.writeln(c.cancellationInstructions);
      }
      if (c.notes.isNotEmpty) {
        buffer.writeln('Notizen:      ${c.notes}');
      }
      buffer.writeln();
    }

    buffer.writeln('Erstellt mit Pacto – softbrewstudio.com');
    return buffer.toString();
  }
}
