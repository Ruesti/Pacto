import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/database/database.dart';
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
}
