import 'package:drift/drift.dart' show Value;
import '../database/database.dart';

/// Wandelt einen [Contract] in die serialisierbare Form fuer verschluesselte
/// Cloud-Backups um (anonymer `sync_data`-Pfad UND Account-`account_vaults`-
/// Pfad nutzen dasselbe Format). Bekannte Luecke, nicht Teil dieses Mappers:
/// `contractKind` und die Login-Felder werden bewusst nicht mitgesichert —
/// das spiegelt das bestehende Verhalten von vor diesem Refactor.
Map<String, dynamic> contractToMap(Contract c) => {
      'id': c.id,
      'name': c.name,
      'entryType': c.entryType.name,
      'accessCategory': c.accessCategory?.name,
      'category': c.category.name,
      'provider': c.provider,
      'contactPhone': c.contactPhone,
      'contactEmail': c.contactEmail,
      'contactUrl': c.contactUrl,
      'cancellationMethod': c.cancellationMethod.name,
      'cancellationInstructions': c.cancellationInstructions,
      'noticePeriod': c.noticePeriod,
      'monthlyCost': c.monthlyCost,
      'billingCycle': c.billingCycle.name,
      'documentPath': c.documentPath,
      'notes': c.notes,
      'contractStart': c.contractStart?.toIso8601String(),
      'nextRenewal': c.nextRenewal?.toIso8601String(),
      'createdAt': c.createdAt.toIso8601String(),
      'updatedAt': c.updatedAt.toIso8601String(),
    };

Map<String, dynamic> heirToMap(Heir h) => {
      'id': h.id,
      'name': h.name,
      'email': h.email,
      'pinHash': h.pinHash,
      'accessLevel': h.accessLevel.name,
      'isActive': h.isActive,
      'createdAt': h.createdAt.toIso8601String(),
    };

Map<String, dynamic> buildBackupPayload({
  required List<Contract> contracts,
  required List<Heir> heirs,
}) =>
    {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'contracts': contracts.map(contractToMap).toList(),
      'heirs': heirs.map(heirToMap).toList(),
    };

/// Rueckrichtung von [contractToMap] — baut aus einem entschluesselten
/// Backup-Eintrag eine einfuegbare [ContractsCompanion], inkl. der
/// urspruenglichen `id` (Restore ersetzt, statt neue IDs zu vergeben).
ContractsCompanion contractCompanionFromMap(Map<String, dynamic> m) =>
    ContractsCompanion(
      id: Value(m['id'] as String),
      name: Value(m['name'] as String),
      entryType: Value(EntryType.values.byName(m['entryType'] as String)),
      accessCategory: Value(m['accessCategory'] == null
          ? null
          : AccessCategory.values.byName(m['accessCategory'] as String)),
      category: Value(ContractCategory.values.byName(m['category'] as String)),
      provider: Value(m['provider'] as String),
      contactPhone: Value(m['contactPhone'] as String?),
      contactEmail: Value(m['contactEmail'] as String?),
      contactUrl: Value(m['contactUrl'] as String?),
      cancellationMethod: Value(
          CancellationMethod.values.byName(m['cancellationMethod'] as String)),
      cancellationInstructions: Value(m['cancellationInstructions'] as String),
      noticePeriod: Value(m['noticePeriod'] as String),
      monthlyCost: Value((m['monthlyCost'] as num).toDouble()),
      billingCycle:
          Value(BillingCycle.values.byName(m['billingCycle'] as String)),
      documentPath: Value(m['documentPath'] as String?),
      notes: Value(m['notes'] as String),
      contractStart: Value(m['contractStart'] == null
          ? null
          : DateTime.parse(m['contractStart'] as String)),
      nextRenewal: Value(m['nextRenewal'] == null
          ? null
          : DateTime.parse(m['nextRenewal'] as String)),
      createdAt: Value(DateTime.parse(m['createdAt'] as String)),
      updatedAt: Value(DateTime.parse(m['updatedAt'] as String)),
    );

HeirsCompanion heirCompanionFromMap(Map<String, dynamic> m) => HeirsCompanion(
      id: Value(m['id'] as String),
      name: Value(m['name'] as String),
      email: Value(m['email'] as String),
      pinHash: Value(m['pinHash'] as String),
      accessLevel: Value(HeirAccess.values.byName(m['accessLevel'] as String)),
      isActive: Value(m['isActive'] as bool),
      createdAt: Value(DateTime.parse(m['createdAt'] as String)),
    );
