import 'package:drift/drift.dart';

class UserProfile extends Table {
  // Single row table — always id = 1
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get gender => text().withDefault(const Constant('male'))();
  // 'male' | 'female' | 'other'
  RealColumn get weightKg => real().withDefault(const Constant(70.0))();
  IntColumn get age => integer().withDefault(const Constant(25))();
  TextColumn get unitPreference => text().withDefault(const Constant('metric'))();
  // 'metric' (ml/kg) | 'imperial' (oz/lbs)
  IntColumn get dailyGoalMl => integer().withDefault(const Constant(2500))();
  TextColumn get wakeTime => text().withDefault(const Constant('07:00'))();
  // stored as 'HH:mm' string
  TextColumn get sleepTime => text().withDefault(const Constant('23:00'))();
  IntColumn get reminderCount => integer().withDefault(const Constant(6))();
  // premium: up to unlimited, free: capped at 6
  BoolColumn get remindersEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get customNotificationText => text().nullable()();
  // null = default "Time to drink water!"
  IntColumn get quickAdd1Ml => integer().withDefault(const Constant(250))();
  IntColumn get quickAdd2Ml => integer().withDefault(const Constant(500))();
  BoolColumn get isPremium => boolean().withDefault(const Constant(false))();
  BoolColumn get onboardingComplete => boolean().withDefault(const Constant(false))();
  TextColumn get premiumProductId => text().nullable()();
  // stores the active subscription product ID

  @override
  Set<Column> get primaryKey => {id};
}
