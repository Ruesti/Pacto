// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contracts_dao.dart';

// ignore_for_file: type=lint
mixin _$ContractsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ContractsTable get contracts => attachedDatabase.contracts;
  ContractsDaoManager get managers => ContractsDaoManager(this);
}

class ContractsDaoManager {
  final _$ContractsDaoMixin _db;
  ContractsDaoManager(this._db);
  $$ContractsTableTableManager get contracts =>
      $$ContractsTableTableManager(_db.attachedDatabase, _db.contracts);
}
