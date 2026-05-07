import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/water_logs_table.dart';

part 'water_log_dao.g.dart';

@DriftAccessor(tables: [WaterLogs])
class WaterLogDao extends DatabaseAccessor<AppDatabase>
    with _$WaterLogDaoMixin {
  WaterLogDao(super.db);

  // INSERT a new water log entry
  Future<int> logWater({
    required int amountMl,
    String source = 'app',
    DateTime? loggedAt,
  }) =>
      into(waterLogs).insert(
        WaterLogsCompanion.insert(
          amountMl: amountMl,
          source: Value(source),
          loggedAt: loggedAt != null ? Value(loggedAt) : const Value.absent(),
        ),
      );

  // DELETE the most recent log entry (undo)
  Future<int> undoLastLog() async {
    final latest = await (select(waterLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.loggedAt)])
          ..limit(1))
        .getSingleOrNull();
    if (latest == null) return 0;
    return (delete(waterLogs)..where((t) => t.id.equals(latest.id))).go();
  }

  // DELETE a specific log by ID (undo per-entry from history list)
  Future<int> deleteLogById(int id) =>
      (delete(waterLogs)..where((t) => t.id.equals(id))).go();

  // GET today's total intake in ml
  Future<int> getTodayTotalMl() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = selectOnly(waterLogs)
      ..addColumns([waterLogs.amountMl.sum()])
      ..where(waterLogs.loggedAt.isBiggerOrEqualValue(startOfDay))
      ..where(waterLogs.loggedAt.isSmallerThanValue(endOfDay));

    final result = await query.getSingleOrNull();
    return result?.read(waterLogs.amountMl.sum()) ?? 0;
  }

  // GET all logs for a specific date
  Future<List<WaterLog>> getLogsForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(waterLogs)
          ..where((t) => t.loggedAt.isBiggerOrEqualValue(start))
          ..where((t) => t.loggedAt.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.loggedAt)]))
        .get();
  }

  // GET last 7 days daily totals — returns list of (date, totalMl)
  Future<List<DailyTotal>> getLast7DaysTotals() async {
    final now = DateTime.now();
    final results = <DailyTotal>[];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final start = DateTime(day.year, day.month, day.day);
      final end = start.add(const Duration(days: 1));

      final query = selectOnly(waterLogs)
        ..addColumns([waterLogs.amountMl.sum()])
        ..where(waterLogs.loggedAt.isBiggerOrEqualValue(start))
        ..where(waterLogs.loggedAt.isSmallerThanValue(end));

      final row = await query.getSingleOrNull();
      final total = row?.read(waterLogs.amountMl.sum()) ?? 0;
      results.add(DailyTotal(date: start, totalMl: total));
    }
    return results;
  }

  // GET today's in-app log count (source = 'app') for interstitial trigger
  Future<int> getTodayAppLogCount() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final query = selectOnly(waterLogs)
      ..addColumns([waterLogs.id.count()])
      ..where(waterLogs.loggedAt.isBiggerOrEqualValue(start))
      ..where(waterLogs.loggedAt.isSmallerThanValue(end))
      ..where(waterLogs.source.equals('app'));

    final result = await query.getSingleOrNull();
    return result?.read(waterLogs.id.count()) ?? 0;
  }

  // WATCH today's logs as a stream (for real-time dashboard updates)
  Stream<List<WaterLog>> watchTodayLogs() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (select(waterLogs)
          ..where((t) => t.loggedAt.isBiggerOrEqualValue(start))
          ..where((t) => t.loggedAt.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.loggedAt)]))
        .watch();
  }

  // WATCH today's total as a stream
  Stream<int> watchTodayTotalMl() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final query = selectOnly(waterLogs)
      ..addColumns([waterLogs.amountMl.sum()])
      ..where(waterLogs.loggedAt.isBiggerOrEqualValue(start))
      ..where(waterLogs.loggedAt.isSmallerThanValue(end));

    return query.watchSingleOrNull().map((row) =>
        row?.read(waterLogs.amountMl.sum()) ?? 0);
  }
}

class DailyTotal {
  final DateTime date;
  final int totalMl;
  const DailyTotal({required this.date, required this.totalMl});
}
