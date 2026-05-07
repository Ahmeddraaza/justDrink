import 'package:drift/drift.dart';

class WaterLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get loggedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get amountMl => integer()();  // stored always in ml
  TextColumn get source => text().withDefault(const Constant('app'))();
  // source: 'app' | 'widget' — helps with interstitial trigger logic
}
