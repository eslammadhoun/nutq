import 'package:drift/drift.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/core/database/tables.dart';

part 'models_dao.g.dart';

@DriftAccessor(tables: [InstalledModels])
class ModelsDao extends DatabaseAccessor<AppDatabase> with _$ModelsDaoMixin {
  ModelsDao(super.db);

  Future<List<InstalledModelRow>> listInstalled() => select(installedModels).get();

  Future<InstalledModelRow?> getInstalled(String modelId) =>
      (select(installedModels)..where((t) => t.modelId.equals(modelId))).getSingleOrNull();

  Future<void> upsert(InstalledModelsCompanion entry) =>
      into(installedModels).insertOnConflictUpdate(entry);

  Future<void> deleteModel(String modelId) =>
      (delete(installedModels)..where((t) => t.modelId.equals(modelId))).go();
}
