import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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

  /// Erzeugt eine PDF-Datei mit der kompletten Vertragsuebersicht und gibt
  /// den lokalen Pfad zurueck. Login-Daten werden hier bewusst NICHT
  /// einbezogen — fuer einen erbe-spezifischen Export inkl. Logins
  /// `buildHeirExportPdf` verwenden.
  static Future<File> exportToPdf(
      List<Contract> contracts, String ownerName) async {
    final bytes = await _renderPdf(
      contracts: contracts,
      ownerName: ownerName,
      titleLine: 'PACTO – VERTRAGSUEBERSICHT',
      introLines: const [],
      includeLogins: false,
    );
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/pacto_vertraege_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Erbe-spezifischer PDF-Export. Beruecksichtigt die [HeirPasswordPolicy]
  /// analog zu [buildHeirExportText]: `none` blendet Login-Block aus,
  /// `komfort` druckt Klartext-Passwoerter, `maximum` druckt den unter
  /// `heirPin` re-encrypteten Cipher.
  static Future<File> buildHeirExportPdf({
    required List<Contract> contracts,
    required String ownerName,
    required Heir heir,
    required HeirPasswordPolicy policy,
    required CryptoService crypto,
    String? heirPin,
  }) async {
    final bytes = await buildHeirExportPdfBytes(
      contracts: contracts,
      ownerName: ownerName,
      heir: heir,
      policy: policy,
      crypto: crypto,
      heirPin: heirPin,
    );
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/pacto_erbe_${heir.id.substring(0, 8)}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Wie [buildHeirExportPdf], liefert aber die PDF-Bytes direkt zurueck,
  /// ohne eine Datei anzulegen. Fuer den serverseitigen Tresor-Versand
  /// (vault-sync), der das PDF base64-kodiert hochlaedt und kein lokales
  /// File braucht.
  static Future<List<int>> buildHeirExportPdfBytes({
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

    final loginBlocks = <String, List<List<String>>>{};
    for (final c in contracts) {
      final block = await _resolveLoginBlock(c, policy, crypto, heirPin);
      if (block.isNotEmpty) loginBlocks[c.id] = block;
    }

    final intro = switch (policy) {
      HeirPasswordPolicy.none => [
          '$ownerName hat in Pacto bewusst keine Passwoerter gespeichert.',
          'Wo Login-Daten benoetigt werden, steht ggf. ein Hinweis unter dem Vertrag.',
        ],
      HeirPasswordPolicy.komfort => [
          'Login-Daten stehen unten im Klartext. Bitte vertraulich behandeln.',
        ],
      HeirPasswordPolicy.maximum => [
          'Login-Passwoerter sind verschluesselt.',
          'Du benoetigst deinen vorab erhaltenen Pacto-PIN, um sie zu entschluesseln.',
        ],
    };

    return _renderPdf(
      contracts: contracts,
      ownerName: ownerName,
      titleLine: 'PACTO – UEBERSICHT FUER ${heir.name.toUpperCase()}',
      introLines: intro,
      includeLogins: true,
      loginBlocks: loginBlocks,
    );
  }

  /// Pro Vertrag eine Liste von Schluessel-Wert-Paaren fuer den Login-Block.
  /// Leer wenn kein Login hinterlegt oder Policy = none.
  static Future<List<List<String>>> _resolveLoginBlock(
    Contract c,
    HeirPasswordPolicy policy,
    CryptoService crypto,
    String? heirPin,
  ) async {
    final hasUsername = (c.loginUsername ?? '').isNotEmpty;
    final hasPassword = c.loginPasswordCt != null;
    final hasHint = (c.loginHint ?? '').isNotEmpty;
    if (!hasUsername && !hasPassword && !hasHint) return const [];

    final rows = <List<String>>[];
    if (hasUsername) rows.add(['Benutzer', c.loginUsername!]);

    if (hasPassword) {
      switch (policy) {
        case HeirPasswordPolicy.none:
          break;
        case HeirPasswordPolicy.komfort:
          try {
            final plain = await crypto.decryptString(c.loginPasswordCt!);
            rows.add(['Passwort', plain]);
          } catch (_) {
            rows.add(['Passwort', '(Fehler beim Entschluesseln)']);
          }
          break;
        case HeirPasswordPolicy.maximum:
          try {
            final plain = await crypto.decryptString(c.loginPasswordCt!);
            final reCt = await crypto.encryptWithPin(plain, heirPin!);
            rows.add(['Passwort', '[verschluesselt, PIN benoetigt]']);
            rows.add(['Cipher', reCt]);
          } catch (_) {
            rows.add(['Passwort', '(Fehler bei Verschluesselung)']);
          }
          break;
      }
    }
    if (hasHint) rows.add(['Hinweis', c.loginHint!]);
    if (c.loginLastVerifiedAt != null) {
      rows.add(['Zuletzt bestaetigt', formatDate(c.loginLastVerifiedAt)]);
    }
    return rows;
  }

  static Future<List<int>> _renderPdf({
    required List<Contract> contracts,
    required String ownerName,
    required String titleLine,
    required List<String> introLines,
    required bool includeLogins,
    Map<String, List<List<String>>>? loginBlocks,
  }) async {
    final doc = pw.Document(
      title: 'Pacto Export',
      author: 'Pacto',
    );

    final total = contracts.fold(0.0, (s, c) => s + c.monthlyCost);

    pw.Widget header() => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(titleLine,
                style: pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('Erstellt: ${formatDate(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10)),
            pw.Text('Inhaber: $ownerName',
                style: const pw.TextStyle(fontSize: 10)),
            pw.Text('Vertraulich – Nur fuer Hinterbliebene',
                style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey700)),
            pw.SizedBox(height: 6),
            pw.Divider(thickness: 0.5),
          ],
        );

    pw.Widget summary() => pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Gesamtkosten: ${formatMonthlyCost(total)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Anzahl Vertraege: ${contracts.length}'),
            ],
          ),
        );

    pw.Widget contractBlock(Contract c) {
      final rows = <List<String>>[
        ['Anbieter', c.provider],
        ['Kategorie', c.category.label],
        ['Kosten', formatMonthlyCost(c.monthlyCost)],
        ['Kuendigung', c.cancellationMethod.label],
        if (c.noticePeriod.isNotEmpty) ['Frist', c.noticePeriod],
        if (c.nextRenewal != null)
          ['Verlaengerung', formatDate(c.nextRenewal)],
        if (c.contactPhone != null) ['Telefon', c.contactPhone!],
        if (c.contactEmail != null) ['E-Mail', c.contactEmail!],
        if (c.contactUrl != null) ['Website', c.contactUrl!],
      ];

      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 14),
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(c.name,
                style: pw.TextStyle(
                    fontSize: 13, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            _kvTable(rows),
            if (includeLogins && (loginBlocks?[c.id]?.isNotEmpty ?? false)) ...[
              pw.SizedBox(height: 8),
              pw.Text('Login',
                  style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800)),
              pw.SizedBox(height: 2),
              _kvTable(loginBlocks![c.id]!, monospaceValue: true),
            ],
            if (c.cancellationInstructions.isNotEmpty) ...[
              pw.SizedBox(height: 8),
              pw.Text('Anleitung',
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Text(c.cancellationInstructions,
                  style: const pw.TextStyle(fontSize: 10)),
            ],
            if (c.notes.isNotEmpty) ...[
              pw.SizedBox(height: 6),
              pw.Text('Notizen',
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Text(c.notes, style: const pw.TextStyle(fontSize: 10)),
            ],
          ],
        ),
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        footer: (ctx) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 12),
          child: pw.Text(
            'Pacto – softbrewstudio.com   Seite ${ctx.pageNumber} / ${ctx.pagesCount}',
            style:
                const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ),
        build: (ctx) => [
          header(),
          pw.SizedBox(height: 12),
          if (introLines.isNotEmpty) ...[
            for (final line in introLines)
              pw.Text(line, style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 10),
          ],
          summary(),
          pw.SizedBox(height: 14),
          ...contracts.map(contractBlock),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _kvTable(List<List<String>> rows,
      {bool monospaceValue = false}) {
    return pw.Table(
      columnWidths: const {
        0: pw.FixedColumnWidth(110),
        1: pw.FlexColumnWidth(),
      },
      children: [
        for (final r in rows)
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 2, right: 6),
                child: pw.Text('${r[0]}:',
                    style: pw.TextStyle(
                        fontSize: 10, color: PdfColors.grey700)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 2),
                child: pw.Text(
                  r[1],
                  style: pw.TextStyle(
                    fontSize: 10,
                    font: monospaceValue ? pw.Font.courier() : null,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
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
