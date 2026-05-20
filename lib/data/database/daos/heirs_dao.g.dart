// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heirs_dao.dart';

// ignore_for_file: type=lint
mixin _$HeirsDaoMixin on DatabaseAccessor<AppDatabase> {
  $HeirsTable get heirs => attachedDatabase.heirs;
  HeirsDaoManager get managers => HeirsDaoManager(this);
}

class HeirsDaoManager {
  final _$HeirsDaoMixin _db;
  HeirsDaoManager(this._db);
  $$HeirsTableTableManager get heirs =>
      $$HeirsTableTableManager(_db.attachedDatabase, _db.heirs);
}
