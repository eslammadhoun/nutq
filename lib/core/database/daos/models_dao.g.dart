// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models_dao.dart';

// ignore_for_file: type=lint
mixin _$ModelsDaoMixin on DatabaseAccessor<AppDatabase> {
  $InstalledModelsTable get installedModels => attachedDatabase.installedModels;
  ModelsDaoManager get managers => ModelsDaoManager(this);
}

class ModelsDaoManager {
  final _$ModelsDaoMixin _db;
  ModelsDaoManager(this._db);
  $$InstalledModelsTableTableManager get installedModels =>
      $$InstalledModelsTableTableManager(
        _db.attachedDatabase,
        _db.installedModels,
      );
}
