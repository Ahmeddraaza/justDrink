import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/water_logs_table.dart';
import 'tables/user_profile_table.dart';
import 'daos/water_log_dao.dart';
import 'daos/user_profile_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [WaterLogs, UserProfile],
  daos: [WaterLogDao, UserProfileDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Used in tests — in-memory database
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      // Seed default UserProfile row (id=1)
      await into(userProfile).insertOnConflictUpdate(
        UserProfileCompanion.insert(
          id: const Value(1),
        ),
      );
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Future migrations here
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'justdrink.db'));
    return NativeDatabase.createInBackground(file);
  });
}
