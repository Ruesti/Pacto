import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/models/contract_category.dart';
import '../../../domain/models/cancellation_method.dart';

class ProviderLibrary extends Table {
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

  @override
  Set<Column> get primaryKey => {id};
}
