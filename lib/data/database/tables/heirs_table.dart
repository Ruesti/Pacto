import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/models/heir_access.dart';

class Heirs extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get pinHash => text()();
  TextColumn get accessLevel =>
      textEnum<HeirAccess>().withDefault(const Constant('nurListe'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column> get primaryKey => {id};
}
