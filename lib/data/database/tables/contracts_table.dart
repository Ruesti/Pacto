import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/models/contract_category.dart';
import '../../../domain/models/cancellation_method.dart';
import '../../../domain/models/billing_cycle.dart';

class Contracts extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get name => text()();
  TextColumn get category =>
      textEnum<ContractCategory>().withDefault(const Constant('sonstiges'))();
  TextColumn get provider => text()();
  TextColumn get contactPhone => text().nullable()();
  TextColumn get contactEmail => text().nullable()();
  TextColumn get contactUrl => text().nullable()();
  TextColumn get cancellationMethod =>
      textEnum<CancellationMethod>().withDefault(const Constant('online'))();
  TextColumn get cancellationInstructions =>
      text().withDefault(const Constant(''))();
  TextColumn get noticePeriod => text().withDefault(const Constant(''))();
  RealColumn get monthlyCost => real().withDefault(const Constant(0.0))();
  TextColumn get billingCycle =>
      textEnum<BillingCycle>().withDefault(const Constant('monthly'))();
  TextColumn get documentPath => text().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  // Optionaler Klartext-Login-Name (z.B. E-Mail) — nicht verschluesselt, weil
  // er allein keinen Zugriff erlaubt.
  TextColumn get loginUsername => text().nullable()();
  // Passwort wird IMMER als verschluesselter JSON-Envelope {v, iv, ct}
  // gespeichert (AES-256-GCM mit dem App-Key). Im Erbfall wird das Passwort
  // gemaess HeirPasswordPolicy fuer den Erben re-encrypted oder im Klartext
  // weitergegeben.
  TextColumn get loginPasswordCt => text().nullable()();
  // Freitext "Wo findest du das Login?" — Alternative wenn der User keine
  // Passwoerter in Pacto speichern moechte.
  TextColumn get loginHint => text().nullable()();
  // Letztes Mal, dass der User explizit bestaetigt hat, dass das Passwort
  // noch stimmt. Bildet Drift-Warnungen ("seit X Monaten nicht bestaetigt").
  DateTimeColumn get loginLastVerifiedAt => dateTime().nullable()();
  DateTimeColumn get contractStart => dateTime().nullable()();
  DateTimeColumn get nextRenewal => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column> get primaryKey => {id};
}
