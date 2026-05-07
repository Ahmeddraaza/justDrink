import 'package:get_it/get_it.dart';
import '../data/database/app_database.dart';

class DatabaseService {
  static AppDatabase? _db;

  static AppDatabase get instance {
    assert(_db != null, 'DatabaseService not initialized');
    return _db!;
  }

  static Future<void> initialize() async {
    _db = AppDatabase();
  }

  // Register in GetIt DI container
  static void registerWithGetIt(GetIt sl) {
    sl.registerLazySingleton<AppDatabase>(() => _db!);
    sl.registerLazySingleton(() => _db!.waterLogDao);
    sl.registerLazySingleton(() => _db!.userProfileDao);
  }

  static Future<void> dispose() async {
    await _db?.close();
    _db = null;
  }
}
