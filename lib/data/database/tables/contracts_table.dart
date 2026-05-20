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
  DateTimeColumn get contractStart => dateTime().nullable()();
  DateTimeColumn get nextRenewal => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column> get primaryKey => {id};
}
