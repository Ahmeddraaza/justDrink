# JustDrink — Implementation Blueprint
## Part 1: Folder Structure & Database Schema

---

# 1. PROFESSIONAL FOLDER STRUCTURE

```
justdrink/
├── android/
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── kotlin/com/justdrink/app/
│   │   │   │   ├── MainActivity.kt
│   │   │   │   ├── WidgetProvider.kt           # AppWidgetProvider for home widget
│   │   │   │   ├── WidgetUpdateReceiver.kt     # BroadcastReceiver for widget taps
│   │   │   │   └── NotificationReceiver.kt     # BroadcastReceiver for notification actions
│   │   │   ├── res/
│   │   │   │   ├── layout/
│   │   │   │   │   └── widget_layout.xml
│   │   │   │   └── xml/
│   │   │   │       └── widget_info.xml
│   │   │   └── AndroidManifest.xml
│   └── build.gradle
├── ios/
│   ├── Runner/
│   │   ├── AppDelegate.swift
│   │   └── Info.plist
│   ├── JustDrinkWidget/                        # WidgetKit extension target
│   │   ├── JustDrinkWidget.swift
│   │   ├── JustDrinkWidgetBundle.swift
│   │   ├── JustDrinkWidgetEntryView.swift
│   │   └── Info.plist
│   └── Runner.xcodeproj/
├── lib/
│   ├── main.dart                               # Entry point, DI setup, BLoC providers
│   ├── app.dart                                # MaterialApp + GoRouter + theme
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart              # Ad unit IDs, product IDs, widget keys
│   │   │   ├── route_constants.dart            # All route path strings
│   │   │   └── notification_constants.dart     # Channel IDs, action IDs, category IDs
│   │   ├── theme/
│   │   │   ├── app_theme.dart                  # ThemeData light/dark
│   │   │   ├── app_colors.dart                 # Color palette
│   │   │   └── app_text_styles.dart            # TextStyle definitions
│   │   ├── utils/
│   │   │   ├── hydration_calculator.dart       # Goal formula (gender+weight+age)
│   │   │   ├── unit_converter.dart             # ml ↔ oz, kg ↔ lbs
│   │   │   ├── notification_scheduler.dart     # Smart spacing algorithm
│   │   │   └── date_utils.dart                 # Date helpers (today, startOfDay, etc.)
│   │   ├── extensions/
│   │   │   ├── datetime_extensions.dart
│   │   │   └── int_extensions.dart             # e.g., ml formatting
│   │   └── di/
│   │       └── injection.dart                  # GetIt or manual DI setup
│   │
│   ├── data/
│   │   ├── database/
│   │   │   ├── app_database.dart               # Drift database class
│   │   │   ├── app_database.g.dart             # Generated
│   │   │   ├── tables/
│   │   │   │   ├── water_logs_table.dart       # WaterLogs Drift table
│   │   │   │   └── user_profile_table.dart     # UserProfile Drift table
│   │   │   └── daos/
│   │   │       ├── water_log_dao.dart          # All water log queries
│   │   │       └── user_profile_dao.dart       # Profile queries
│   │   └── preferences/
│   │       └── preferences_service.dart        # shared_preferences wrapper
│   │
│   ├── services/
│   │   ├── database_service.dart               # Drift init + injection wrapper
│   │   ├── notification_service.dart           # Full notification engine
│   │   ├── widget_service.dart                 # home_widget sync service
│   │   ├── purchase_service.dart               # in_app_purchase service
│   │   └── ad_service.dart                     # google_mobile_ads service
│   │
│   ├── features/
│   │   ├── onboarding/
│   │   │   ├── cubit/
│   │   │   │   ├── onboarding_cubit.dart
│   │   │   │   └── onboarding_state.dart
│   │   │   └── screens/
│   │   │       ├── onboarding_step1_screen.dart  # Welcome + details
│   │   │       ├── onboarding_step2_screen.dart  # Sleep schedule
│   │   │       └── onboarding_step3_screen.dart  # Goal + permissions
│   │   │
│   │   ├── dashboard/
│   │   │   ├── cubit/
│   │   │   │   ├── dashboard_cubit.dart
│   │   │   │   └── dashboard_state.dart
│   │   │   ├── screens/
│   │   │   │   └── dashboard_screen.dart
│   │   │   └── widgets/
│   │   │       ├── progress_ring_widget.dart    # Circular progress ring
│   │   │       ├── quick_add_button.dart        # +250ml / +500ml buttons
│   │   │       └── undo_button.dart             # Undo last log button
│   │   │
│   │   ├── history/
│   │   │   ├── cubit/
│   │   │   │   ├── history_cubit.dart
│   │   │   │   └── history_state.dart
│   │   │   ├── screens/
│   │   │   │   └── history_screen.dart
│   │   │   └── widgets/
│   │   │       ├── weekly_bar_chart.dart        # fl_chart bar chart
│   │   │       └── log_entry_tile.dart          # Individual log row
│   │   │
│   │   ├── settings/
│   │   │   ├── cubit/
│   │   │   │   ├── settings_cubit.dart
│   │   │   │   └── settings_state.dart
│   │   │   ├── screens/
│   │   │   │   ├── settings_screen.dart
│   │   │   │   ├── custom_volume_edit_screen.dart  # Premium
│   │   │   │   └── custom_notification_text_screen.dart  # Premium
│   │   │   └── widgets/
│   │   │       └── settings_tile.dart
│   │   │
│   │   ├── paywall/
│   │   │   ├── cubit/
│   │   │   │   ├── purchase_cubit.dart
│   │   │   │   └── purchase_state.dart
│   │   │   └── screens/
│   │   │       └── paywall_screen.dart
│   │   │
│   │   └── splash/
│   │       └── screens/
│   │           └── splash_screen.dart
│   │
│   └── shared/
│       ├── cubits/
│       │   ├── ad/
│       │   │   ├── ad_cubit.dart
│       │   │   └── ad_state.dart
│       │   ├── notification/
│       │   │   ├── notification_cubit.dart
│       │   │   └── notification_state.dart
│       │   └── widget_sync/
│       │       ├── widget_sync_cubit.dart
│       │       └── widget_sync_state.dart
│       └── widgets/
│           ├── banner_ad_widget.dart            # Reusable banner ad container
│           ├── premium_gate_widget.dart         # Wraps premium-only content
│           └── loading_overlay.dart
│
├── test/
│   ├── unit/
│   │   ├── hydration_calculator_test.dart
│   │   ├── notification_scheduler_test.dart
│   │   ├── water_log_dao_test.dart
│   │   └── user_profile_dao_test.dart
│   ├── widget/
│   │   ├── dashboard_screen_test.dart
│   │   └── paywall_screen_test.dart
│   └── bloc/
│       ├── dashboard_cubit_test.dart
│       └── onboarding_cubit_test.dart
│
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

# 2. DRIFT DATABASE SCHEMA

## 2.1 Tables

### `water_logs_table.dart`
```dart
import 'package:drift/drift.dart';

class WaterLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get loggedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get amountMl => integer()();  // stored always in ml
  TextColumn get source => text().withDefault(const Constant('app'))();
  // source: 'app' | 'widget' — helps with interstitial trigger logic
}
```

### `user_profile_table.dart`
```dart
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
```

## 2.2 AppDatabase Class

### `app_database.dart`
```dart
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
```

## 2.3 DAOs

### `water_log_dao.dart`
```dart
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
```

### `user_profile_dao.dart`
```dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/user_profile_table.dart';

part 'user_profile_dao.g.dart';

@DriftAccessor(tables: [UserProfile])
class UserProfileDao extends DatabaseAccessor<AppDatabase>
    with _$UserProfileDaoMixin {
  UserProfileDao(super.db);

  // GET the single profile row
  Future<UserProfileData?> getProfile() =>
      (select(userProfile)..where((t) => t.id.equals(1))).getSingleOrNull();

  // WATCH profile stream for reactive UI
  Stream<UserProfileData?> watchProfile() =>
      (select(userProfile)..where((t) => t.id.equals(1))).watchSingleOrNull();

  // UPDATE weight
  Future<void> updateWeight(double weightKg) => (update(userProfile)
        ..where((t) => t.id.equals(1)))
      .write(UserProfileCompanion(weightKg: Value(weightKg)));

  // UPDATE age
  Future<void> updateAge(int age) => (update(userProfile)
        ..where((t) => t.id.equals(1)))
      .write(UserProfileCompanion(age: Value(age)));

  // UPDATE wake/sleep times + triggers reschedule externally
  Future<void> updateSchedule({
    required String wakeTime,
    required String sleepTime,
  }) =>
      (update(userProfile)..where((t) => t.id.equals(1))).write(
        UserProfileCompanion(
          wakeTime: Value(wakeTime),
          sleepTime: Value(sleepTime),
        ),
      );

  // UPDATE reminders enabled toggle
  Future<void> updateRemindersEnabled(bool enabled) =>
      (update(userProfile)..where((t) => t.id.equals(1)))
          .write(UserProfileCompanion(remindersEnabled: Value(enabled)));

  // UPDATE unit preference
  Future<void> updateUnitPreference(String unit) =>
      (update(userProfile)..where((t) => t.id.equals(1)))
          .write(UserProfileCompanion(unitPreference: Value(unit)));

  // UPDATE daily goal
  Future<void> updateDailyGoal(int goalMl) =>
      (update(userProfile)..where((t) => t.id.equals(1)))
          .write(UserProfileCompanion(dailyGoalMl: Value(goalMl)));

  // UPDATE isPremium flag
  Future<void> updatePremiumStatus({
    required bool isPremium,
    String? productId,
  }) =>
      (update(userProfile)..where((t) => t.id.equals(1))).write(
        UserProfileCompanion(
          isPremium: Value(isPremium),
          premiumProductId: Value(productId),
        ),
      );

  // UPDATE custom notification text (premium)
  Future<void> updateCustomNotificationText(String? text) =>
      (update(userProfile)..where((t) => t.id.equals(1)))
          .write(UserProfileCompanion(customNotificationText: Value(text)));

  // UPDATE custom quick-add button volumes (premium)
  Future<void> updateQuickAddVolumes({
    required int quickAdd1Ml,
    required int quickAdd2Ml,
  }) =>
      (update(userProfile)..where((t) => t.id.equals(1))).write(
        UserProfileCompanion(
          quickAdd1Ml: Value(quickAdd1Ml),
          quickAdd2Ml: Value(quickAdd2Ml),
        ),
      );

  // UPDATE onboarding complete flag
  Future<void> completeOnboarding() =>
      (update(userProfile)..where((t) => t.id.equals(1))).write(
        const UserProfileCompanion(onboardingComplete: Value(true)),
      );

  // UPSERT full profile during onboarding
  Future<void> upsertProfile(UserProfileCompanion companion) =>
      into(userProfile).insertOnConflictUpdate(companion);

  // UPDATE reminder count
  Future<void> updateReminderCount(int count) =>
      (update(userProfile)..where((t) => t.id.equals(1)))
          .write(UserProfileCompanion(reminderCount: Value(count)));
}
```
# JustDrink — Implementation Blueprint
## Part 2: BLoC/Cubit Architecture

---

# 3. BLOC / CUBIT ARCHITECTURE PLAN

---

## 3.1 OnboardingCubit

**File:** `lib/features/onboarding/cubit/onboarding_cubit.dart`

```dart
// State
class OnboardingState {
  final int currentStep;          // 0, 1, 2
  final String gender;            // 'male' | 'female' | 'other'
  final double weightKg;
  final int age;
  final String unitPreference;    // 'metric' | 'imperial'
  final String wakeTime;          // 'HH:mm'
  final String sleepTime;         // 'HH:mm'
  final int calculatedGoalMl;
  final bool notificationPermissionGranted;
  final bool isLoading;
  final String? errorMessage;
}
```

**Methods:**
- `setGender(String gender)` → updates gender field, emits new state
- `setWeight(double weight)` → converts to kg internally if imperial, emits
- `setAge(int age)` → emits updated age
- `toggleUnit()` → switches metric/imperial, recalculates display weight
- `setWakeTime(String time)` → emits updated wakeTime
- `setSleepTime(String time)` → emits updated sleepTime
- `calculateGoal()` → calls `HydrationCalculator.calculate(gender, weightKg, age)`, emits calculatedGoalMl
- `requestNotificationPermission()` → calls `NotificationService.requestPermission()`, emits permission result
- `completeOnboarding()` → calls `UserProfileDao.upsertProfile(...)`, calls `UserProfileDao.completeOnboarding()`, calls `NotificationService.scheduleAll(profile)`, calls `WidgetService.updateWidget(...)`, emits step = done
- `nextStep()` → increments currentStep

**DAOs/Services called:** `UserProfileDao`, `NotificationService`, `WidgetService`

---

## 3.2 DashboardCubit

**File:** `lib/features/dashboard/cubit/dashboard_cubit.dart`

```dart
// State
class DashboardState {
  final int currentIntakeMl;
  final int dailyGoalMl;
  final List<WaterLog> todayLogs;  // from DAO watch stream
  final int quickAdd1Ml;           // default 250, premium editable
  final int quickAdd2Ml;           // default 500, premium editable
  final bool isPremium;
  final bool showUndo;             // true after any log action
  final int? lastLoggedId;         // for undo
  final int appLogCountToday;      // for interstitial trigger (every 3rd)
  final bool isLoading;
}
```

**Methods:**
- `initialize()` → watches `WaterLogDao.watchTodayTotalMl()` stream, loads profile from DAO, emits initial state
- `logWater(int amountMl)` → calls `WaterLogDao.logWater(amountMl: amountMl, source: 'app')`, increments `appLogCountToday`, stores lastLoggedId, sets `showUndo = true`, emits. After emit, checks if `appLogCountToday % 3 == 0` → fires `AdCubit.showInterstitial()`
- `logFromWidget(int amountMl)` → calls `WaterLogDao.logWater(amountMl: amountMl, source: 'widget')` — does NOT count toward interstitial counter
- `undoLastLog()` → calls `WaterLogDao.undoLastLog()`, sets `showUndo = false`, emits
- `refresh()` → re-fetches todayTotal and logs, emits updated state

**DAOs/Services called:** `WaterLogDao`, `UserProfileDao`, `AdCubit`, `WidgetSyncCubit`

**Interstitial counter persistence:** `appLogCountToday` is loaded from `PreferencesService` on init and persisted on each log. Key: `'ad_log_counter'`. Reset daily by checking stored date.

---

## 3.3 HistoryCubit

**File:** `lib/features/history/cubit/history_cubit.dart`

```dart
// State
class HistoryState {
  final List<DailyTotal> last7Days;   // for bar chart
  final List<WaterLog> todayLogs;     // scrollable list
  final int dailyGoalMl;
  final bool isPremium;
  final bool isLoading;
}
```

**Methods:**
- `loadHistory()` → calls `WaterLogDao.getLast7DaysTotals()` and `WaterLogDao.getLogsForDate(today)` and `UserProfileDao.getProfile()`, emits loaded state
- `deleteLog(int logId)` → calls `WaterLogDao.deleteLogById(logId)`, calls `loadHistory()` to refresh, emits. Also triggers `WidgetSyncCubit.sync()`

**DAOs/Services called:** `WaterLogDao`, `UserProfileDao`, `WidgetSyncCubit`

---

## 3.4 SettingsCubit

**File:** `lib/features/settings/cubit/settings_cubit.dart`

```dart
// State
class SettingsState {
  final UserProfileData? profile;
  final bool isLoading;
  final String? successMessage;
  final String? errorMessage;
}
```

**Methods:**
- `loadSettings()` → watches `UserProfileDao.watchProfile()` stream, emits loaded state
- `updateWeight(double weightKg)` → calls `UserProfileDao.updateWeight(weightKg)`, recalculates goal via `HydrationCalculator`, calls `UserProfileDao.updateDailyGoal(newGoal)`, emits success
- `updateAge(int age)` → calls `UserProfileDao.updateAge(age)`, recalculates and updates goal, emits success
- `updateSchedule(String wake, String sleep)` → calls `UserProfileDao.updateSchedule(...)`, calls `NotificationService.rescheduleAll(wake, sleep)`, emits success
- `toggleReminders(bool enabled)` → calls `UserProfileDao.updateRemindersEnabled(enabled)`, if false calls `NotificationService.cancelAll()`, if true calls `NotificationService.scheduleAll(profile)`, emits
- `updateReminderCount(int count)` → validates premium constraint (max 6 for free), calls `UserProfileDao.updateReminderCount(count)`, calls `NotificationService.rescheduleAll(...)`, emits
- `updateCustomNotificationText(String? text)` → premium only, calls DAO, reschedules notifications, emits
- `updateQuickAddVolumes(int v1, int v2)` → premium only, calls `UserProfileDao.updateQuickAddVolumes(...)`, emits

**DAOs/Services called:** `UserProfileDao`, `NotificationService`, `HydrationCalculator`

---

## 3.5 NotificationCubit

**File:** `lib/shared/cubits/notification/notification_cubit.dart`

```dart
// State
class NotificationState {
  final bool permissionGranted;
  final bool remindersActive;
  final List<String> scheduledTimes;  // human-readable for debug/settings
  final bool isLoading;
}
```

**Methods:**
- `checkPermissionStatus()` → calls `NotificationService.checkPermission()`, emits
- `requestPermission()` → calls `NotificationService.requestPermission()`, emits result
- `scheduleReminders(UserProfileData profile)` → calls `NotificationService.scheduleAll(profile)`, emits scheduledTimes
- `cancelAllReminders()` → calls `NotificationService.cancelAll()`, emits remindersActive = false

**Services called:** `NotificationService`

---

## 3.6 PurchaseCubit

**File:** `lib/features/paywall/cubit/purchase_cubit.dart`

```dart
// State
class PurchaseState {
  final List<ProductDetails> products;  // loaded from store
  final String? selectedProductId;
  final bool isPremium;
  final bool isLoading;
  final bool isPurchasing;
  final String? errorMessage;
  final String? successMessage;
}
```

**Methods:**
- `initialize()` → calls `PurchaseService.initialize()`, loads products, checks existing premium status from `PreferencesService`, emits
- `selectProduct(String productId)` → emits selectedProductId
- `purchase()` → calls `PurchaseService.purchase(selectedProductId)`, sets isPurchasing = true, emits. Result delivered via stream in `PurchaseService`
- `restorePurchases()` → calls `PurchaseService.restorePurchases()`, emits loading then result
- `_onPurchaseSuccess(String productId)` → calls `UserProfileDao.updatePremiumStatus(isPremium: true, productId: productId)`, persists to `PreferencesService`, emits isPremium = true, successMessage

**Services called:** `PurchaseService`, `UserProfileDao`, `PreferencesService`

---

## 3.7 AdCubit

**File:** `lib/shared/cubits/ad/ad_cubit.dart`

```dart
// State
class AdState {
  final bool isPremium;
  final bool isBannerLoaded;
  final bool isInterstitialLoaded;
  final bool isInterstitialShowing;
}
```

**Methods:**
- `initialize(bool isPremium)` → if not premium: calls `AdService.loadBanner()`, calls `AdService.loadInterstitial()`, emits
- `showInterstitial()` → if not premium and interstitial loaded: calls `AdService.showInterstitial()`, emits isInterstitialShowing = true. After closed: calls `AdService.loadInterstitial()` to preload next
- `dispose()` → calls `AdService.disposeBanner()`, `AdService.disposeInterstitial()`
- `onPremiumUnlocked()` → calls `AdService.disposeAll()`, sets isPremium = true, emits — all ads removed immediately

**Services called:** `AdService`

---

## 3.8 WidgetSyncCubit

**File:** `lib/shared/cubits/widget_sync/widget_sync_cubit.dart`

```dart
// State
class WidgetSyncState {
  final bool isSyncing;
  final DateTime? lastSyncedAt;
  final bool syncError;
}
```

**Methods:**
- `sync()` → fetches today's total from `WaterLogDao.getTodayTotalMl()`, fetches goal from `UserProfileDao`, calls `WidgetService.updateWidget(currentMl, goalMl, isPremium)`, emits lastSyncedAt
- `handleWidgetTap(int amountMl)` → called when app is opened from a widget tap (via URI intent), calls `WaterLogDao.logWater(amountMl: amountMl, source: 'widget')`, then calls `sync()`

**Services called:** `WidgetService`, `WaterLogDao`, `UserProfileDao`
# JustDrink Blueprint — Part 3: Screens & Navigation

---

# 4. COMPLETE SCREEN LIST WITH IMPLEMENTATION DETAIL

## Route Constants (`lib/core/constants/route_constants.dart`)
```dart
class Routes {
  static const splash            = '/';
  static const onboardingStep1   = '/onboarding/1';
  static const onboardingStep2   = '/onboarding/2';
  static const onboardingStep3   = '/onboarding/3';
  static const dashboard         = '/dashboard';
  static const history           = '/history';
  static const settings          = '/settings';
  static const paywall           = '/paywall';
  static const customVolume      = '/settings/custom-volume';
  static const customNotifText   = '/settings/custom-notification';
}
```

## go_router Setup (`lib/app.dart`)
```dart
final _router = GoRouter(
  initialLocation: Routes.splash,
  redirect: (context, state) async {
    final prefs = GetIt.I<PreferencesService>();
    final onboarded = await prefs.getBool('onboarding_complete') ?? false;
    if (!onboarded && !state.uri.path.startsWith('/onboarding') && state.uri.path != '/') {
      return Routes.onboardingStep1;
    }
    return null;
  },
  routes: [
    GoRoute(path: Routes.splash,          builder: (c,s) => const SplashScreen()),
    GoRoute(path: Routes.onboardingStep1, builder: (c,s) => const OnboardingStep1Screen()),
    GoRoute(path: Routes.onboardingStep2, builder: (c,s) => const OnboardingStep2Screen()),
    GoRoute(path: Routes.onboardingStep3, builder: (c,s) => const OnboardingStep3Screen()),
    GoRoute(path: Routes.dashboard,       builder: (c,s) => const DashboardScreen()),
    GoRoute(path: Routes.history,         builder: (c,s) => const HistoryScreen()),
    GoRoute(path: Routes.settings,        builder: (c,s) => const SettingsScreen()),
    GoRoute(path: Routes.paywall,         builder: (c,s) => const PaywallScreen()),
    GoRoute(path: Routes.customVolume,    builder: (c,s) => const CustomVolumeEditScreen()),
    GoRoute(path: Routes.customNotifText, builder: (c,s) => const CustomNotificationTextScreen()),
  ],
);
```

---

## Screen 1: SplashScreen
**File:** `lib/features/splash/screens/splash_screen.dart`
**Route:** `/`
**Cubits:** none (reads SharedPreferences directly)

**Widgets:**
- Full-screen gradient background (deep blue → cyan)
- Centered SVG/PNG JustDrink logo + app name text
- Tagline: "Build a Pure Habit" in light subtitle style
- AnimatedOpacity fade-in on mount (500ms)

**Logic on mount (`initState`):**
1. Wait 1.5 seconds (brand moment)
2. Check `PreferencesService.getBool('onboarding_complete')`
3. If false → `context.go(Routes.onboardingStep1)`
4. If true → `context.go(Routes.dashboard)`

---

## Screen 2: OnboardingStep1Screen
**File:** `lib/features/onboarding/screens/onboarding_step1_screen.dart`
**Route:** `/onboarding/1`
**Cubits:** `OnboardingCubit`

**Widgets:**
- Scaffold with gradient background
- Title: "Let's calculate your daily goal."
- **Gender selector:** Row of 3 segmented buttons (Male / Female / Other)
  - On tap → `cubit.setGender(value)`
- **Weight field:** TextFormField (numeric keyboard)
  - Suffix row: "kg" / "lbs" toggle buttons
  - On toggle → `cubit.toggleUnit()` (converts displayed value)
  - On change → `cubit.setWeight(double.parse(value))`
- **Age field:** TextFormField (numeric keyboard)
  - On change → `cubit.setAge(int.parse(value))`
- **Next button:** Elevated CTA "Next →"
  - Validates all fields non-empty
  - On tap → `cubit.nextStep()` + `context.go(Routes.onboardingStep2)`

**Platform notes:** None specific.

---

## Screen 3: OnboardingStep2Screen
**File:** `lib/features/onboarding/screens/onboarding_step2_screen.dart`
**Route:** `/onboarding/2`
**Cubits:** `OnboardingCubit`

**Widgets:**
- Title: "YOUR TIME"
- Subtitle: "Wake & Sleep — This bounds your reminders."
- **Wake Up time picker:**
  - Tappable row showing current time (default 07:00)
  - On tap → `showTimePicker(context, initialTime: ...)` → `cubit.setWakeTime(result)`
- **Sleep time picker:**
  - Same pattern, default 23:00
  - On tap → `showTimePicker(...)` → `cubit.setSleepTime(result)`
- **Next button:** "Next →"
  - On tap → `cubit.nextStep()` + `context.go(Routes.onboardingStep3)`

---

## Screen 4: OnboardingStep3Screen
**File:** `lib/features/onboarding/screens/onboarding_step3_screen.dart`
**Route:** `/onboarding/3`
**Cubits:** `OnboardingCubit`

**Widgets:**
- Title: "Your Daily Goal"
- **Large goal display:** e.g., "2,500 ml" in hero typography
  - Derived from `cubit.state.calculatedGoalMl`
- Body copy: "Hydration plan is ready. Allow notifications for your reminders."
- **CTA button:** "Start Reminders"
  - On tap:
    1. `cubit.requestNotificationPermission()` — triggers OS native prompt
    2. `await` result (granted or denied)
    3. `cubit.completeOnboarding()` — saves profile to DB
    4. `context.go(Routes.dashboard)`
- **Note:** If permission denied, still navigate to dashboard. Settings can redirect user to OS settings later.

---

## Screen 5: DashboardScreen
**File:** `lib/features/dashboard/screens/dashboard_screen.dart`
**Route:** `/dashboard`
**Cubits:** `DashboardCubit`, `AdCubit`, `WidgetSyncCubit`

**Widgets (top to bottom):**
- AppBar:
  - Title: "JustDrink" logo/text (centered)
  - Actions: `IconButton(icon: Icon(Icons.settings))` → `context.push(Routes.settings)`
- **ProgressRingWidget** (center, ~220px diameter):
  - Animated circular progress arc using `CustomPainter`
  - Center text: "1,250 / 2,500 ml" (currentIntake / goal)
  - Percentage text below: "50%"
  - Animation: `AnimatedBuilder` + `Tween<double>` on progress value (300ms ease)
- **Quick Add Buttons Row:**
  - `QuickAddButton(label: '+${state.quickAdd1Ml}ml Glass', onTap: () => cubit.logWater(state.quickAdd1Ml))`
  - `QuickAddButton(label: '+${state.quickAdd2Ml}ml Bottle', onTap: () => cubit.logWater(state.quickAdd2Ml))`
- **"Log other amount"** TextButton:
  - On tap → `showModalBottomSheet` with a numeric TextField + "Log" button
  - On confirm → `cubit.logWater(customAmount)`
- **UndoButton** (`AnimatedOpacity`, only visible when `state.showUndo == true`):
  - Text: "↩ Undo"
  - On tap → `cubit.undoLastLog()`
  - Auto-hides after 5 seconds via Timer in cubit
- **Bottom Navigation:** Row with Dashboard (selected) | History icons
  - History tap → `context.go(Routes.history)`
- **BannerAdWidget** (pinned to very bottom, free users only):
  - `BlocBuilder<AdCubit, AdState>` → show if `!state.isPremium && state.isBannerLoaded`

**User Actions & Triggers:**
| Action | Cubit Method | Side Effect |
|--------|-------------|-------------|
| Tap +250ml | `cubit.logWater(250)` | DB insert, widget sync, check interstitial |
| Tap +500ml | `cubit.logWater(500)` | DB insert, widget sync, check interstitial |
| Log custom | `cubit.logWater(n)` | Same as above |
| Tap Undo | `cubit.undoLastLog()` | DB delete, widget sync |
| 3rd in-app log | `AdCubit.showInterstitial()` | Interstitial ad shown |

---

## Screen 6: HistoryScreen
**File:** `lib/features/history/screens/history_screen.dart`
**Route:** `/history`
**Cubits:** `HistoryCubit`, `AdCubit`

**Widgets:**
- AppBar: "History" title
- **WeeklyBarChart** (fl_chart):
  - 7 bars, one per day (Mon–Sun)
  - Bar color: accent blue if goal met, muted grey if not
  - Y-axis: 0 to dailyGoalMl + 20% headroom
  - Horizontal dashed line at dailyGoalMl
  - Data: `state.last7Days` (list of DailyTotal)
- **"Today's Log" section header**
- **Scrollable ListView** of `LogEntryTile`:
  - Each tile: timestamp (e.g., "2:45 PM") + amount ("250 ml") + undo icon
  - Undo icon tap → `cubit.deleteLog(log.id)` + `WidgetSyncCubit.sync()`
- **BannerAdWidget** pinned to bottom (free users only)

---

## Screen 7: SettingsScreen
**File:** `lib/features/settings/screens/settings_screen.dart`
**Route:** `/settings`
**Cubits:** `SettingsCubit`, `PurchaseCubit`

**Widgets:**
- AppBar: "Settings" + back button
- **Section 1: Your Details**
  - `SettingsTile`: "Weight" → tappable, shows edit dialog with kg/lbs toggle, on save `cubit.updateWeight(v)`
  - `SettingsTile`: "Age" → tappable, shows edit dialog, on save `cubit.updateAge(v)`
- **Section 2: Reminders**
  - `SettingsTile`: "Wake Up" → time picker, on change `cubit.updateSchedule(...)`
  - `SettingsTile`: "Bed Time" → time picker, on change `cubit.updateSchedule(...)`
  - `SwitchListTile`: "Drink Reminders" → on toggle `cubit.toggleReminders(v)`
- **Section 3: Go Pro Banner** (free users only, `BlocBuilder<PurchaseCubit>`):
  - Card with gradient background
  - Bullet list: Ad-Free, Unlimited Reminders, Custom Notifications, Advanced Widgets
  - Button: "Explore JustDrink Pro" → `context.push(Routes.paywall)`
- **Premium-only tiles** (wrapped in `PremiumGateWidget`):
  - "Custom Quick-Add Volumes" → `context.push(Routes.customVolume)`
  - "Custom Notification Text" → `context.push(Routes.customNotifText)`

---

## Screen 8: PaywallScreen
**File:** `lib/features/paywall/screens/paywall_screen.dart`
**Route:** `/paywall`
**Cubits:** `PurchaseCubit`

**Widgets:**
- Gradient background (dark navy → deep blue)
- Header: "JUSTDRINK PRO" in bold uppercase
- Subheadline: "Master your hydration habit. Reach your goals faster."
- Social proof: ⭐ "Loved by thousands!"
- **Feature list** (ListView of rows with icons):
  - 💧 Personalized Hydration Goal
  - 🔔 Custom Reminders & Paces
  - 📊 Advanced Health Insights
  - 🚫 Completely Ad-Free
  - 🎨 Premium Widget Themes
- **Plan Selector** (two cards side by side):
  - Annual card: "$19.99/yr · $1.66/mo" + "MOST POPULAR" badge
  - Monthly card: "$3.49/mo"
  - Selected state: glowing border + check icon
  - On tap → `cubit.selectProduct(productId)`
- **Primary CTA:** "UNLOCK PRO FOR \$0 (7-Day Free Trial)"
  - On tap → `cubit.purchase()`
  - Shows `CircularProgressIndicator` when `state.isPurchasing`
- **"Restore Purchases"** TextButton → `cubit.restorePurchases()`
- **Fine print:** "Cancel anytime. Free trial reverts to standard billing."
- **Links:** "Terms of Service | Privacy Policy" (opens in-app WebView or browser)

---

## Screen 9: CustomVolumeEditScreen (Premium)
**File:** `lib/features/settings/screens/custom_volume_edit_screen.dart`
**Route:** `/settings/custom-volume`
**Cubits:** `SettingsCubit`

**Widgets:**
- AppBar: "Custom Quick-Add"
- Two labeled TextFields: "Button 1 (ml)" and "Button 2 (ml)"
- Pre-filled with current values from `state.profile.quickAdd1Ml` and `quickAdd2Ml`
- Labels preview: e.g., "+330ml Can"
- Save button → `cubit.updateQuickAddVolumes(v1, v2)` → pop

---

## Screen 10: CustomNotificationTextScreen (Premium)
**File:** `lib/features/settings/screens/custom_notification_text_screen.dart`
**Route:** `/settings/custom-notification`
**Cubits:** `SettingsCubit`

**Widgets:**
- AppBar: "Custom Reminder Text"
- TextField (multiline, max 100 chars)
- Character counter (e.g., "42/100")
- Pre-filled with `state.profile.customNotificationText ?? 'Time to drink water!'`
- Save button → `cubit.updateCustomNotificationText(text)` → triggers `NotificationService.rescheduleAll(...)` → pop
- "Reset to default" TextButton → `cubit.updateCustomNotificationText(null)`
# JustDrink Blueprint — Part 4: Services Layer

---

# 5. SERVICES LAYER

---

## 5.1 DatabaseService
**File:** `lib/services/database_service.dart`

```dart
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
```

**Initialization in `main.dart`:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.initialize();
  DatabaseService.registerWithGetIt(GetIt.I);
  await PreferencesService.initialize();
  // Register remaining services...
  runApp(const JustDrinkApp());
}
```

---

## 5.2 NotificationService
**File:** `lib/services/notification_service.dart`

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/constants/notification_constants.dart';
import '../core/utils/notification_scheduler.dart';
import '../data/database/daos/user_profile_dao.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ── Initialization ──────────────────────────────────────────────────
  Future<void> initialize() async {
    // Android notification action buttons require DarwinNotificationAction
    // for iOS and AndroidNotificationAction for Android.

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS: Register action categories here
    final iosInit = DarwinInitializationSettings(
      notificationCategories: [
        DarwinNotificationCategory(
          NotificationConstants.hydrationCategoryId,
          actions: [
            DarwinNotificationAction.plain(
              NotificationConstants.actionLog250,
              'Log 250ml',
              options: {DarwinNotificationActionOption.foreground: false},
            ),
            DarwinNotificationAction.plain(
              NotificationConstants.actionSnooze10,
              'Snooze 10m',
              options: {DarwinNotificationActionOption.foreground: false},
            ),
          ],
        ),
      ],
    );

    await _plugin.initialize(
      InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationResponse,
    );
  }

  // ── Permission ───────────────────────────────────────────────────────
  Future<bool> requestPermission() async {
    // Android 13+ (API 33+): POST_NOTIFICATIONS must be requested at runtime
    // This is handled by flutter_local_notifications v14+ automatically
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission() ?? false;

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);

    return granted;
  }

  Future<bool> checkPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final status = await android?.areNotificationsEnabled() ?? false;
    return status;
  }

  // ── Smart Schedule ───────────────────────────────────────────────────
  // Algorithm:
  //   1. Parse wakeTime ('HH:mm') and sleepTime ('HH:mm') to TimeOfDay
  //   2. Calculate totalAwakeMinutes = sleepMinutes - wakeMinutes
  //   3. intervalMinutes = totalAwakeMinutes / (reminderCount + 1)
  //   4. Generate N times: wakeTime + (i * intervalMinutes) for i in 1..N
  //   5. All times guaranteed within [wakeTime, sleepTime]
  //
  // Example: wake=07:00, sleep=23:00, count=6
  //   awake=960min, interval=137min
  //   Times: 09:17, 11:34, 13:51, 16:08, 18:25, 20:42

  Future<void> scheduleAll({
    required String wakeTime,
    required String sleepTime,
    required int reminderCount,     // already capped by free/premium logic
    required String notificationText,
    required bool isPremium,
  }) async {
    await cancelAll();

    final times = NotificationScheduler.generate(
      wakeTime: wakeTime,
      sleepTime: sleepTime,
      count: reminderCount,
    );

    for (int i = 0; i < times.length; i++) {
      final time = times[i];
      await _plugin.zonedSchedule(
        i,
        'JustDrink 💧',
        notificationText,
        time,
        NotificationDetails(
          android: AndroidNotificationDetails(
            NotificationConstants.channelId,
            NotificationConstants.channelName,
            channelDescription: NotificationConstants.channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            actions: [
              // Android action buttons — handled by BroadcastReceiver
              AndroidNotificationAction(
                NotificationConstants.actionLog250,
                'Log 250ml',
                cancelNotification: true,
              ),
              AndroidNotificationAction(
                NotificationConstants.actionSnooze10,
                'Snooze 10m',
                cancelNotification: true,
              ),
            ],
          ),
          iOS: DarwinNotificationDetails(
            categoryIdentifier: NotificationConstants.hydrationCategoryId,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        // Repeats daily at same time
      );
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> rescheduleAll(UserProfileData profile) async {
    final text = profile.customNotificationText ?? 'Time to drink water!';
    final count = profile.isPremium
        ? profile.reminderCount
        : profile.reminderCount.clamp(1, 6);
    await scheduleAll(
      wakeTime: profile.wakeTime,
      sleepTime: profile.sleepTime,
      reminderCount: count,
      notificationText: text,
      isPremium: profile.isPremium,
    );
  }

  // ── Action Handling ──────────────────────────────────────────────────
  // Foreground / background (app running) response
  static void _onNotificationResponse(NotificationResponse response) {
    _handleAction(response.actionId, response.id);
  }

  // Background / killed app response — must be top-level function
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) {
    _handleAction(response.actionId, response.id);
  }

  static Future<void> _handleAction(String? actionId, int? notifId) async {
    if (actionId == NotificationConstants.actionLog250) {
      // Log 250ml directly — open DB and insert
      // NOTE: On Android, this runs in an isolate via the BroadcastReceiver
      // The Dart isolate must reinitialize the DB connection
      final db = AppDatabase();
      await db.waterLogDao.logWater(amountMl: 250, source: 'widget');
      await _updateWidgetAfterBackgroundLog(db);
      await db.close();
    } else if (actionId == NotificationConstants.actionSnooze10) {
      // Cancel this notification and reschedule it 10 minutes from now
      final plugin = FlutterLocalNotificationsPlugin();
      if (notifId != null) {
        await plugin.cancel(notifId);
        final snoozeTime = tz.TZDateTime.now(tz.local).add(
          const Duration(minutes: 10),
        );
        await plugin.zonedSchedule(
          notifId + 1000, // offset to avoid collision
          'JustDrink 💧',
          'Time to drink water! (Snoozed)',
          snoozeTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              NotificationConstants.channelId,
              NotificationConstants.channelName,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }
  }

  static Future<void> _updateWidgetAfterBackgroundLog(AppDatabase db) async {
    final total = await db.waterLogDao.getTodayTotalMl();
    final profile = await db.userProfileDao.getProfile();
    if (profile != null) {
      await HomeWidget.saveWidgetData('currentMl', total);
      await HomeWidget.saveWidgetData('goalMl', profile.dailyGoalMl);
      await HomeWidget.updateWidget(
        androidName: 'JustDrinkWidgetProvider',
        iOSName: 'JustDrinkWidget',
      );
    }
  }
}
```

### `lib/core/constants/notification_constants.dart`
```dart
class NotificationConstants {
  static const channelId             = 'justdrink_reminders';
  static const channelName           = 'Hydration Reminders';
  static const channelDesc           = 'Daily water reminder notifications';
  static const hydrationCategoryId   = 'hydration_category';
  static const actionLog250          = 'action_log_250';
  static const actionSnooze10        = 'action_snooze_10';
}
```

### `lib/core/utils/notification_scheduler.dart`
```dart
import 'package:timezone/timezone.dart' as tz;

class NotificationScheduler {
  /// Generates [count] evenly-spaced TZDateTime instances
  /// strictly within the [wakeTime]–[sleepTime] window.
  static List<tz.TZDateTime> generate({
    required String wakeTime,   // 'HH:mm'
    required String sleepTime,  // 'HH:mm'
    required int count,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    final wakeParts  = wakeTime.split(':').map(int.parse).toList();
    final sleepParts = sleepTime.split(':').map(int.parse).toList();

    final wakeMinutes  = wakeParts[0] * 60 + wakeParts[1];
    final sleepMinutes = sleepParts[0] * 60 + sleepParts[1];
    final awakeMinutes = sleepMinutes - wakeMinutes;

    // interval between each reminder (not before first, not after last)
    final intervalMinutes = awakeMinutes ~/ (count + 1);

    return List.generate(count, (i) {
      final minutesFromMidnight = wakeMinutes + (intervalMinutes * (i + 1));
      final hour   = minutesFromMidnight ~/ 60;
      final minute = minutesFromMidnight % 60;

      var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute,
      );
      // If already passed today, schedule for tomorrow
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      return scheduled;
    });
  }
}
```

---

## 5.3 WidgetService
**File:** `lib/services/widget_service.dart`

```dart
import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const _appGroupId   = 'group.com.justdrink.app';  // iOS App Group
  static const _androidClass = 'com.justdrink.app.JustDrinkWidgetProvider';
  static const _iOSName      = 'JustDrinkWidget';

  Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_appGroupId);
    // Register callback for when widget button is tapped
    HomeWidget.registerInteractivityCallback(_widgetBackgroundCallback);
  }

  // Called by any cubit after data changes
  Future<void> updateWidget({
    required int currentMl,
    required int goalMl,
    required bool isPremium,
    String theme = 'default',
  }) async {
    await HomeWidget.saveWidgetData<int>('currentMl', currentMl);
    await HomeWidget.saveWidgetData<int>('goalMl', goalMl);
    await HomeWidget.saveWidgetData<String>('theme', isPremium ? theme : 'default');
    await HomeWidget.saveWidgetData<double>(
      'progress',
      goalMl > 0 ? (currentMl / goalMl).clamp(0.0, 1.0) : 0.0,
    );
    await HomeWidget.updateWidget(
      androidName: _androidClass,
      iOSName: _iOSName,
    );
  }

  // Handles widget tap that opens app with amount intent
  Future<void> handleInitialUri() async {
    final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (uri != null) {
      _processWidgetUri(uri);
    }
  }

  // Listen for widget taps while app is in foreground
  Stream<Uri?> get widgetLaunchStream => HomeWidget.widgetClicked;

  static void _processWidgetUri(Uri uri) {
    // URI format: justdrink://log?amount=250
    // Handled by WidgetSyncCubit.handleWidgetTap()
  }
}

// Top-level background callback — must be @pragma annotated
@pragma('vm:entry-point')
Future<void> _widgetBackgroundCallback(Uri? uri) async {
  if (uri == null) return;
  final amount = int.tryParse(uri.queryParameters['amount'] ?? '') ?? 0;
  if (amount <= 0) return;

  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  await db.waterLogDao.logWater(amountMl: amount, source: 'widget');

  final total   = await db.waterLogDao.getTodayTotalMl();
  final profile = await db.userProfileDao.getProfile();
  if (profile != null) {
    await HomeWidget.saveWidgetData('currentMl', total);
    await HomeWidget.saveWidgetData('goalMl', profile.dailyGoalMl);
    await HomeWidget.saveWidgetData(
      'progress',
      profile.dailyGoalMl > 0
          ? (total / profile.dailyGoalMl).clamp(0.0, 1.0)
          : 0.0,
    );
    await HomeWidget.updateWidget(
      androidName: 'com.justdrink.app.JustDrinkWidgetProvider',
      iOSName: 'JustDrinkWidget',
    );
  }
  await db.close();
}
```

### iOS Platform Setup (WidgetKit)
```
1. In Xcode: File > New > Target > Widget Extension
   Name: JustDrinkWidget
   Bundle ID: com.justdrink.app.JustDrinkWidget

2. Add App Group to BOTH Runner and Widget targets:
   Capability: App Groups → group.com.justdrink.app

3. In JustDrinkWidget.swift:
   - Read UserDefaults(suiteName: "group.com.justdrink.app")
   - Keys: currentMl, goalMl, progress, theme
   - Render SwiftUI view with progress bar and two buttons
   - Button intents: AppIntentTimelineProvider with
     custom AppIntent for log250 and log500
   - Buttons call URL scheme: justdrink://log?amount=250

4. Info.plist of widget extension:
   NSExtension > NSExtensionPointIdentifier = com.apple.widgetkit-extension

5. Runner Info.plist: add CFBundleURLTypes with scheme 'justdrink'
```

### Android Platform Setup (AppWidgetProvider)
```
1. WidgetProvider.kt extends AppWidgetProvider:
   override fun onUpdate(...) — calls updateAppWidget()
   override fun onReceive(...) — handles button tap broadcasts

2. updateAppWidget() reads SharedPreferences with:
   context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
   Keys: flutter.currentMl, flutter.goalMl, flutter.progress

3. Button intents in widget layout:
   PendingIntent with action "com.justdrink.LOG_250"
   PendingIntent with action "com.justdrink.LOG_500"

4. WidgetUpdateReceiver.kt extends BroadcastReceiver:
   onReceive: reads action, calls Flutter background isolate or
   writes to SharedPreferences + triggers widget update

5. widget_info.xml:
   <appwidget-provider ... updatePeriodMillis="0"
     initialLayout="@layout/widget_layout" />

6. AndroidManifest.xml additions:
   <receiver android:name=".JustDrinkWidgetProvider">
     <intent-filter>
       <action android:name="android.appwidget.action.APPWIDGET_UPDATE"/>
     </intent-filter>
     <meta-data android:name="android.appwidget.provider"
       android:resource="@xml/widget_info"/>
   </receiver>
   <receiver android:name=".WidgetUpdateReceiver">
     <intent-filter>
       <action android:name="com.justdrink.LOG_250"/>
       <action android:name="com.justdrink.LOG_500"/>
     </intent-filter>
   </receiver>
```

---

## 5.4 PurchaseService
**File:** `lib/services/purchase_service.dart`

```dart
import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../data/preferences/preferences_service.dart';

class PurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final _purchaseController = StreamController<PurchaseResult>.broadcast();

  // Product IDs — must match exactly in Play Console and App Store Connect
  // Play Store: products under app com.justdrink.app
  // App Store: products under app bundle com.justdrink.app
  static const productMonthly = 'justdrink_pro_monthly';  // $3.49/mo
  static const productAnnual  = 'justdrink_pro_annual';   // $19.99/yr

  Stream<PurchaseResult> get purchaseResultStream => _purchaseController.stream;

  Future<List<ProductDetails>> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) return [];

    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (e) => _purchaseController.add(PurchaseResult.error(e.toString())),
    );

    final response = await _iap.queryProductDetails({productMonthly, productAnnual});
    return response.productDetails;
  }

  Future<void> purchase(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    // Subscriptions always use buyNonConsumable for iOS
    // Google Play auto-detects subscription type
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
    // Results delivered via purchaseStream → _handlePurchaseUpdates
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Verify locally (no backend) — trust the platform verification
        // For production: add server-side receipt verification if needed
        await _iap.completePurchase(purchase);
        await PreferencesService.instance.setBool('is_premium', true);
        await PreferencesService.instance.setString(
          'premium_product_id', purchase.productID,
        );
        _purchaseController.add(PurchaseResult.success(purchase.productID));
      } else if (purchase.status == PurchaseStatus.error) {
        _purchaseController.add(
          PurchaseResult.error(purchase.error?.message ?? 'Purchase failed'),
        );
      } else if (purchase.status == PurchaseStatus.canceled) {
        _purchaseController.add(PurchaseResult.cancelled());
      }
    }
  }

  Future<bool> checkExistingPremium() async {
    return PreferencesService.instance.getBool('is_premium') ?? false;
  }

  void dispose() {
    _subscription.cancel();
    _purchaseController.close();
  }
}

class PurchaseResult {
  final bool success;
  final bool cancelled;
  final String? productId;
  final String? errorMessage;

  const PurchaseResult._({
    required this.success,
    required this.cancelled,
    this.productId,
    this.errorMessage,
  });

  factory PurchaseResult.success(String productId) =>
      PurchaseResult._(success: true, cancelled: false, productId: productId);
  factory PurchaseResult.error(String msg) =>
      PurchaseResult._(success: false, cancelled: false, errorMessage: msg);
  factory PurchaseResult.cancelled() =>
      PurchaseResult._(success: false, cancelled: true);
}
```

---

## 5.5 AdService
**File:** `lib/services/ad_service.dart`

```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/constants/app_constants.dart';

class AdService {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerLoaded = false;
  bool _isInterstitialLoaded = false;

  // Callbacks
  Function()? onBannerLoaded;
  Function()? onInterstitialLoaded;
  Function()? onInterstitialClosed;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // ── Banner Ad ─────────────────────────────────────────────────────
  void loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: AppConstants.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerLoaded = true;
          onBannerLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isBannerLoaded = false;
        },
      ),
    )..load();
  }

  BannerAd? get bannerAd => _isBannerLoaded ? _bannerAd : null;

  void disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
  }

  // ── Interstitial Ad ───────────────────────────────────────────────
  void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AppConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          onInterstitialLoaded?.call();
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialLoaded = false;
              onInterstitialClosed?.call();
              loadInterstitial(); // preload next
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoaded = false;
        },
      ),
    );
  }

  bool get isInterstitialReady => _isInterstitialLoaded;

  Future<void> showInterstitial() async {
    if (_isInterstitialLoaded && _interstitialAd != null) {
      await _interstitialAd!.show();
    }
  }

  void disposeInterstitial() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialLoaded = false;
  }

  void disposeAll() {
    disposeBanner();
    disposeInterstitial();
  }
}
```

### `lib/core/constants/app_constants.dart`
```dart
class AppConstants {
  // Replace with real ad unit IDs from AdMob console
  // Test IDs for development:
  static const bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  // Widget identifiers
  static const widgetAppGroupId = 'group.com.justdrink.app';
  static const widgetAndroidName = 'com.justdrink.app.JustDrinkWidgetProvider';
  static const widgetIOSName = 'JustDrinkWidget';
}
```

### Interstitial Ad Counter (Persisted)
```dart
// In PreferencesService:
static const _adCounterKey     = 'ad_log_counter';
static const _adCounterDateKey = 'ad_log_counter_date';

Future<int> getAndIncrementAdCounter() async {
  final storedDate = getString(_adCounterDateKey);
  final today = DateTime.now().toIso8601String().substring(0, 10);

  // Reset counter if it's a new day
  if (storedDate != today) {
    await setString(_adCounterDateKey, today);
    await setInt(_adCounterKey, 1);
    return 1;
  }

  final current = getInt(_adCounterKey) ?? 0;
  final next = current + 1;
  await setInt(_adCounterKey, next);
  return next;
}
```
# JustDrink Blueprint — Part 5: Task Breakdown

---

# 6. COMPLETE TASK BREAKDOWN

## PHASE 1 — PROJECT SETUP & INFRASTRUCTURE

**Task 1.1 - Flutter Project Init:** Run `flutter create --org com.justdrink justdrink` in workspace. Set minimum SDK: Android `minSdkVersion 21`, iOS deployment target `14.0`.

**Task 1.2 - pubspec.yaml Dependencies:** Add all packages listed in Section 8. Run `flutter pub get`. Commit lock file.

**Task 1.3 - Folder Structure:** Create every directory and placeholder `.dart` file listed in Section 1 folder tree. Use `// TODO` stubs so all imports resolve.

**Task 1.4 - GetIt DI Setup:** Create `lib/core/di/injection.dart`. Register `AppDatabase`, `WaterLogDao`, `UserProfileDao`, `PreferencesService`, `NotificationService`, `WidgetService`, `PurchaseService`, `AdService` as lazy singletons. Call `configureDependencies()` in `main.dart` before `runApp`.

**Task 1.5 - app_constants.dart:** Populate `AppConstants` with test AdMob IDs, widget group ID, widget class names, and product IDs.

**Task 1.6 - Theme System:** Implement `app_colors.dart` (deep blue `#0A1628`, cyan accent `#00D4FF`, surface `#0F2040`, success green `#00E676`). Implement `app_text_styles.dart` using Google Fonts `Outfit`. Implement `app_theme.dart` returning dark `ThemeData` using these tokens.

**Task 1.7 - GoRouter Setup:** Implement full `GoRouter` in `lib/app.dart` with all routes and redirect guard based on `onboarding_complete` SharedPreferences key.

**Task 1.8 - Android Manifest Permissions:** Add to `AndroidManifest.xml`: `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM`, `POST_NOTIFICATIONS`, `USE_EXACT_ALARM`. Add `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` for API 33+.

**Task 1.9 - iOS Info.plist:** Add `NSUserNotificationUsageDescription`, `CFBundleURLTypes` with scheme `justdrink`, `NSAppTransportSecurity` if needed.

**Task 1.10 - Timezone Init:** Add `flutter_timezone` package. In `main.dart` call `tz.initializeTimeZones()` and `tz.setLocalLocation(tz.getLocation(await FlutterTimezone.getLocalTimezone()))` before `runApp`.

---

## PHASE 2 — DATABASE LAYER

**Task 2.1 - Table Definitions:** Create `lib/data/database/tables/water_logs_table.dart` and `user_profile_table.dart` exactly as specified in Section 2.1.

**Task 2.2 - AppDatabase Class:** Create `lib/data/database/app_database.dart` with `@DriftDatabase` annotation, `schemaVersion = 1`, `MigrationStrategy` seeding default UserProfile row on `onCreate`.

**Task 2.3 - WaterLogDao:** Implement all 8 methods in `water_log_dao.dart`: `logWater`, `undoLastLog`, `deleteLogById`, `getTodayTotalMl`, `getLogsForDate`, `getLast7DaysTotals`, `getTodayAppLogCount`, `watchTodayLogs`, `watchTodayTotalMl`.

**Task 2.4 - UserProfileDao:** Implement all 11 methods in `user_profile_dao.dart` as specified in Section 2.3.

**Task 2.5 - Code Generation:** Run `dart run build_runner build --delete-conflicting-outputs`. Verify `.g.dart` files generated for database, both DAOs, and both tables. Commit generated files.

**Task 2.6 - DatabaseService:** Implement `lib/services/database_service.dart` init + GetIt registration exactly as in Section 5.1.

**Task 2.7 - PreferencesService:** Create `lib/data/preferences/preferences_service.dart`. Wrap `SharedPreferences` with typed getters/setters. Implement `getAndIncrementAdCounter()` with daily reset logic.

**Task 2.8 - HydrationCalculator:** Create `lib/core/utils/hydration_calculator.dart`. Formula: `base = weightKg * 35` (ml). Age adjustment: if age < 30 add 0%, 30-55 subtract 5%, >55 subtract 10%. Gender: male +0%, female -10%, other +0%. Return `int` rounded to nearest 50ml.

---

## PHASE 3 — ONBOARDING FLOW

**Task 3.1 - OnboardingState:** Create `lib/features/onboarding/cubit/onboarding_state.dart` with all fields: `currentStep`, `gender`, `weightKg`, `age`, `unitPreference`, `wakeTime`, `sleepTime`, `calculatedGoalMl`, `notificationPermissionGranted`, `isLoading`, `errorMessage`. Implement `copyWith`.

**Task 3.2 - OnboardingCubit:** Implement all 8 methods in `onboarding_cubit.dart` as specified in Section 3.1. Wire `completeOnboarding()` to call `UserProfileDao.upsertProfile`, `NotificationService.scheduleAll`, `WidgetService.updateWidget`, and `SharedPreferences.setBool('onboarding_complete', true)`.

**Task 3.3 - OnboardingStep1Screen:** Build UI with gradient background, gender segmented buttons (custom `SegmentedButton` widget), weight `TextField` with unit toggle, age `TextField`, Next CTA. Validation: all fields filled before allowing Next.

**Task 3.4 - OnboardingStep2Screen:** Build UI with "YOUR TIME" header, two tappable time-picker rows showing formatted time. Call `showTimePicker` on tap. Validate wake before sleep (sleep must be after wake).

**Task 3.5 - OnboardingStep3Screen:** Build UI showing calculated goal in large hero text. Wire "Start Reminders" button to `cubit.requestNotificationPermission()` then `cubit.completeOnboarding()` then `context.go(Routes.dashboard)`.

---

## PHASE 4 — DASHBOARD & CORE LOGGING

**Task 4.1 - DashboardState:** Create `dashboard_state.dart` with all fields. Implement `copyWith`. Handle `showUndo` timer: after 5s auto-emit `showUndo = false` via `Future.delayed` in cubit.

**Task 4.2 - DashboardCubit:** Implement `initialize()` subscribing to `watchTodayTotalMl` stream. Implement `logWater(int amountMl)` with DB insert, ad counter check, widget sync trigger. Implement `undoLastLog()`. Implement `logFromWidget(int amountMl)`.

**Task 4.3 - ProgressRingWidget:** Create `lib/features/dashboard/widgets/progress_ring_widget.dart`. Use `CustomPainter` with `drawArc` for background track and progress arc. Animate with `AnimationController` + `CurvedAnimation(curve: Curves.easeOut)`. Center text shows "X / Y ml". Ring fills clockwise from top. Color: cyan `#00D4FF` on dark navy `#0A1628` track.

**Task 4.4 - QuickAddButton:** Create `lib/features/dashboard/widgets/quick_add_button.dart`. Styled elevated button with water drop icon, label, subtle ripple. Width: 45% of screen width. Border radius 16px.

**Task 4.5 - DashboardScreen:** Assemble all widgets top to bottom. Wrap with `BlocProvider<DashboardCubit>`. Call `cubit.initialize()` in `initState`. Add `BlocListener` to trigger `AdCubit.showInterstitial()` when cubit emits interstitial trigger. Add bottom nav bar (Dashboard | History).

**Task 4.6 - Custom Amount BottomSheet:** Implement `showModalBottomSheet` with a numeric `TextField` and "Log" button. Dismiss on log. Validate input is positive integer > 0 and <= 5000.

**Task 4.7 - UndoButton:** `AnimatedOpacity` widget that fades in on `state.showUndo == true`. Positioned above quick-add buttons. On tap calls `cubit.undoLastLog()`.

---

## PHASE 5 — NOTIFICATION ENGINE

**Task 5.1 - NotificationService Init:** Implement full `NotificationService.initialize()` in `lib/services/notification_service.dart` registering iOS category with two actions. Call in `main.dart` before `runApp`.

**Task 5.2 - Permission Request:** Implement `requestPermission()` for both Android (using `AndroidFlutterLocalNotificationsPlugin.requestNotificationsPermission()`) and iOS. Handle denial gracefully — store result in `SharedPreferences` key `'notification_permission_asked'`.

**Task 5.3 - NotificationScheduler:** Implement `lib/core/utils/notification_scheduler.dart` `generate()` method exactly as described in Section 5.2. Write unit tests in `test/unit/notification_scheduler_test.dart` covering edge cases: wake=06:00 sleep=22:00 count=6, count=1, count=10.

**Task 5.4 - scheduleAll():** Implement `NotificationService.scheduleAll()`. Use `zonedSchedule` with `matchDateTimeComponents: DateTimeComponents.time` for daily repeating. Pass Android action buttons. Pass iOS category identifier. Cap count at 6 for free users inside this method.

**Task 5.5 - Background Action Handler:** Implement `_onBackgroundNotificationResponse` as a top-level `@pragma('vm:entry-point')` function. For `actionLog250`: re-initialize DB, insert log, update widget data. For `actionSnooze10`: cancel original notification, schedule one-time notification 10 minutes from now with id = originalId + 1000.

**Task 5.6 - Android BroadcastReceiver:** Create `android/app/src/main/kotlin/.../NotificationReceiver.kt` extending `BroadcastReceiver`. Register in AndroidManifest with intent filter for `com.justdrink.LOG_250` and `com.justdrink.SNOOZE_10`. In `onReceive`: call `FlutterBackgroundService` or write to SharedPreferences and trigger widget update.

**Task 5.7 - NotificationCubit:** Implement all 4 methods. Wire to `NotificationService`. Expose `scheduledTimes` as human-readable strings (e.g., "09:17 AM") for Settings screen debug info.

---

## PHASE 6 — HOME SCREEN WIDGET

**Task 6.1 - WidgetService Dart:** Implement `lib/services/widget_service.dart` fully: `initialize()`, `updateWidget()`, `handleInitialUri()`, `widgetLaunchStream`. Register background callback `_widgetBackgroundCallback` as top-level `@pragma` function.

**Task 6.2 - Android Widget Layout:** Create `android/app/src/main/res/layout/widget_layout.xml` with `RemoteViews`-compatible layout: `LinearLayout` containing `TextView` for "X / Y ml", `ProgressBar` (horizontal), two `Button` elements for "+250ml" and "+500ml".

**Task 6.3 - Android WidgetProvider:** Implement `JustDrinkWidgetProvider.kt` extending `AppWidgetProvider`. `onUpdate`: read SharedPreferences (`FlutterSharedPreferences`), build `RemoteViews`, set text, set progress, create `PendingIntent` for each button pointing to `WidgetUpdateReceiver`, call `appWidgetManager.updateAppWidget`.

**Task 6.4 - Android WidgetUpdateReceiver:** Implement `WidgetUpdateReceiver.kt` extending `BroadcastReceiver`. On receive `com.justdrink.LOG_250` or `com.justdrink.LOG_500`: use `FlutterEngineCache` or directly write to SharedPreferences via Android API, then call `sendBroadcast(Intent(AppWidgetManager.ACTION_APPWIDGET_UPDATE))` to force widget redraw.

**Task 6.5 - Android Manifest Widget Entries:** Add `<receiver>` for `JustDrinkWidgetProvider` with `APPWIDGET_UPDATE` intent filter and `<meta-data>` pointing to `@xml/widget_info`. Add `<receiver>` for `WidgetUpdateReceiver` with `LOG_250` and `LOG_500` intent filters.

**Task 6.6 - iOS WidgetKit Target:** In Xcode add Widget Extension target. In `JustDrinkWidget.swift`: create `Provider: TimelineProvider`, `Entry: TimelineEntry`, `EntryView: View`. Read from `UserDefaults(suiteName: "group.com.justdrink.app")`. Render progress bar + two buttons using `Link` with URL `justdrink://log?amount=250`.

**Task 6.7 - iOS App Group:** In Xcode, add App Groups capability to both Runner and Widget targets. Group ID: `group.com.justdrink.app`. Verify entitlements files updated.

**Task 6.8 - WidgetSyncCubit:** Implement `sync()` and `handleWidgetTap(int amountMl)` as specified in Section 3.8. Call `sync()` from `DashboardCubit.logWater()` and `HistoryCubit.deleteLog()`.

**Task 6.9 - URI Deep Link Handling:** In `DashboardScreen.initState`, listen to `WidgetService.widgetLaunchStream` and call `WidgetSyncCubit.handleWidgetTap(amount)` when URI received.

---

## PHASE 7 — HISTORY & SETTINGS SCREENS

**Task 7.1 - HistoryCubit:** Implement `loadHistory()` and `deleteLog(int id)` as specified in Section 3.3.

**Task 7.2 - WeeklyBarChart:** Create `lib/features/history/widgets/weekly_bar_chart.dart` using `fl_chart` `BarChart`. Configure `BarChartGroupData` for 7 days. Color: accent blue if `totalMl >= goalMl`, muted grey otherwise. Add horizontal `FlLine` at `goalMl` value (dashed). X-axis labels: day abbreviations (Mon–Sun). Y-axis: 0 to `goalMl * 1.2`.

**Task 7.3 - LogEntryTile:** Create `lib/features/history/widgets/log_entry_tile.dart`. Row: time text (e.g., "2:45 PM") | amount text ("250 ml") | `IconButton(icon: Icon(Icons.undo))`. On undo tap: `cubit.deleteLog(log.id)`.

**Task 7.4 - HistoryScreen:** Assemble `WeeklyBarChart` + section header "Today's Log" + `ListView.builder` of `LogEntryTile`. Add `BannerAdWidget` at bottom for free users. Call `cubit.loadHistory()` in `initState`.

**Task 7.5 - SettingsCubit:** Implement all methods in `settings_cubit.dart`. Subscribe to `UserProfileDao.watchProfile()` stream in `initialize()`. After each update emit `successMessage` for 2 seconds then clear via `Future.delayed`.

**Task 7.6 - SettingsScreen:** Build 3 sections with `ListView`. Use `ListTile` for each setting. Dialog for weight/age edit. `showTimePicker` for wake/sleep. `SwitchListTile` for reminders toggle. Go Pro card for free users. Premium-only items wrapped in `PremiumGateWidget`.

**Task 7.7 - CustomVolumeEditScreen:** Two `TextFormField` widgets. Validate each is int between 50 and 3000. On save call `SettingsCubit.updateQuickAddVolumes`. Pop on success.

**Task 7.8 - CustomNotificationTextScreen:** `TextFormField` with 100-char limit, char counter. On save call `SettingsCubit.updateCustomNotificationText`. "Reset to default" clears to null. Pop on success.

---

## PHASE 8 — MONETIZATION (ADS + IAP)

**Task 8.1 - AdService:** Implement full `AdService` in `lib/services/ad_service.dart` as in Section 5.5. Use test ad unit IDs for development.

**Task 8.2 - AdCubit:** Implement `initialize(bool isPremium)`, `showInterstitial()`, `dispose()`, `onPremiumUnlocked()`. Connect `onInterstitialClosed` callback to reload next interstitial.

**Task 8.3 - BannerAdWidget:** Create `lib/shared/widgets/banner_ad_widget.dart`. Use `AdWidget(ad: adService.bannerAd!)` inside `SizedBox(height: 50)`. Wrap in `BlocBuilder<AdCubit>` — only show when `!state.isPremium && state.isBannerLoaded`.

**Task 8.4 - Interstitial Trigger in DashboardCubit:** In `logWater()`: after DB insert, call `PreferencesService.getAndIncrementAdCounter()`. If counter % 3 == 0 and not premium: emit a trigger flag in state. `DashboardScreen` `BlocListener` reacts to this flag by calling `AdCubit.showInterstitial()`.

**Task 8.5 - PurchaseService:** Implement full `PurchaseService` as in Section 5.4. Initialize stream subscription. Handle purchased/restored/error/cancelled states.

**Task 8.6 - PurchaseCubit:** Implement all methods. On init: load products from store, check existing premium from `PreferencesService`. On success: update `UserProfileDao.updatePremiumStatus`, call `AdCubit.onPremiumUnlocked()`, call `NotificationService.rescheduleAll` (to remove 6-cap).

**Task 8.7 - PaywallScreen UI:** Build full paywall UI as specified in Section 4 (Screen 8). Wire plan selection to `cubit.selectProduct()`. Wire CTA to `cubit.purchase()`. Show `CircularProgressIndicator` during purchase. Show `SnackBar` on success/error.

---

## PHASE 9 — PREMIUM FEATURES

**Task 9.1 - PremiumGateWidget:** Create `lib/shared/widgets/premium_gate_widget.dart`. Wraps a child widget. If `!isPremium`, shows a locked overlay with "🔒 Pro Feature" text and a "Upgrade" button → navigates to paywall.

**Task 9.2 - Custom Volumes Flow:** Wire `CustomVolumeEditScreen` to `SettingsCubit.updateQuickAddVolumes`. In `DashboardCubit`, read `quickAdd1Ml` and `quickAdd2Ml` from profile and expose in state. `QuickAddButton` labels update reactively.

**Task 9.3 - Custom Notification Text Flow:** Wire `CustomNotificationTextScreen` to `SettingsCubit.updateCustomNotificationText`. After save, call `NotificationService.rescheduleAll(profile)` to apply new text immediately.

**Task 9.4 - Premium Widget Themes:** In `WidgetService.updateWidget()`, pass `theme` string. Android: `WidgetProvider.kt` checks SharedPreferences `flutter.theme` key and applies different `RemoteViews` layout or background color. iOS: Swift widget reads `theme` from shared `UserDefaults` and applies different `Color` or background.

**Task 9.5 - Remove Reminders Cap:** In `NotificationService.scheduleAll()`, cap logic: `count = isPremium ? count : count.clamp(1, 6)`. After premium unlock, call `rescheduleAll` to lift cap immediately.

---

## PHASE 10 — QA & RELEASE PREP

**Task 10.1 - Unit Tests:** Write tests in `test/unit/`: `hydration_calculator_test.dart` (5 test cases), `notification_scheduler_test.dart` (3 edge cases), `water_log_dao_test.dart` (all 8 DAO methods using in-memory `AppDatabase.forTesting`).

**Task 10.2 - Widget Tests:** Write `dashboard_screen_test.dart`: verify progress ring renders, quick-add buttons trigger cubit methods, undo button appears after log and disappears after tap.

**Task 10.3 - BLoC Tests:** Write `dashboard_cubit_test.dart` using `bloc_test` package. Test `logWater` sequence: verify DB called, state emits showUndo=true, counter increments. Test `undoLastLog`: verify DB called, showUndo=false emitted.

**Task 10.4 - Real AdMob IDs:** Replace test IDs in `app_constants.dart` with production AdMob unit IDs from AdMob console. Create separate `app_constants_dev.dart` and `app_constants_prod.dart` with `--dart-define` flavor switching.

**Task 10.5 - Play Console Setup:** Upload signed AAB. Set up subscription products `justdrink_pro_monthly` ($3.49/mo) and `justdrink_pro_annual` ($19.99/yr) with 7-day free trial in Play Console > Monetize > Products > Subscriptions.

**Task 10.6 - App Store Connect Setup:** Create subscription group "JustDrink Pro". Add two products with same IDs. Configure introductory offer (7-day free trial) for both. Submit for App Store review.

**Task 10.7 - Release Build Android:** Run `flutter build appbundle --release`. Sign with keystore. Upload to Play Console internal testing track. Test IAP and ads on real device.

**Task 10.8 - Release Build iOS:** Run `flutter build ipa --release`. Archive via Xcode. Upload to App Store Connect via Transporter or Xcode Organizer. Test via TestFlight.

**Task 10.9 - Widget Real Device Testing:** Test Android widget: long-press home screen > Widgets > JustDrink. Verify +250ml button logs water and updates progress bar without opening app. Test iOS widget on iPhone with WidgetKit sandbox.

**Task 10.10 - Notification End-to-End Testing:** On real Android device: confirm notifications fire at scheduled times, action buttons appear on lock screen, "Log 250ml" button logs water when app is killed. On iOS: confirm same with iOS action categories.
# JustDrink Blueprint — Part 6: Gotchas & pubspec.yaml

---

# 7. TECHNICAL GOTCHAS & PLATFORM NOTES

## 7.1 Android 12+ Notification Permission (POST_NOTIFICATIONS)

- **API 33+** requires `android.permission.POST_NOTIFICATIONS` declared in `AndroidManifest.xml` AND requested at runtime.
- `flutter_local_notifications` v14+ exposes `AndroidFlutterLocalNotificationsPlugin.requestNotificationsPermission()` which triggers the system dialog.
- **Never** assume permission is granted. Always check with `areNotificationsEnabled()` on app resume and show a `SnackBar` with a "Enable" button that opens `openAppSettings()` from `app_settings` package.
- `SCHEDULE_EXACT_ALARM` is required for exact alarm scheduling on Android 12+. On Android 13+ the user can revoke this separately in battery settings. Check with `canScheduleExactAlarms()` before scheduling and fall back to inexact alarms gracefully.
- Declare `<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>` (API 33+) OR `<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>` (API 31+) — use SCHEDULE_EXACT_ALARM (requires user approval) for API 31–32, USE_EXACT_ALARM (auto-granted) for API 33+. Handle both.

## 7.2 Android Notification Action Buttons (Background Handling)

- When the app is **killed**, notification action button taps do NOT wake the Flutter app's Dart isolate on Android. They are delivered to a native `BroadcastReceiver`.
- `flutter_local_notifications` background callback (`onDidReceiveBackgroundNotificationResponse`) runs in a **separate Dart isolate**. You MUST:
  1. Call `WidgetsFlutterBinding.ensureInitialized()` at the start of the callback.
  2. Re-initialize the Drift database (new `AppDatabase()`) since the main isolate is killed.
  3. Re-initialize `home_widget` to update the widget after logging.
  4. Close the DB after use: `await db.close()`.
- Mark the background handler with `@pragma('vm:entry-point')` or it will be tree-shaken in release builds.
- **Critical:** Do not use `GetIt` singleton instances in the background isolate — they are not shared across isolates. Always create fresh instances.

## 7.3 iOS Notification Action Categories Setup

- Categories must be registered in `DarwinInitializationSettings.notificationCategories` during `FlutterLocalNotificationsPlugin.initialize()` — NOT in `AppDelegate.swift`. The package handles the `UNUserNotificationCenter` delegation.
- Set `DarwinNotificationActionOption.foreground: false` for "Log 250ml" so it executes without bringing the app to foreground.
- The `onDidReceiveBackgroundNotificationResponse` handler is called even when app is killed for iOS notification actions.
- Background processing on iOS is limited. Keep the handler fast (< 30 seconds). Drift with `NativeDatabase` works fine in background isolates on iOS.

## 7.4 iOS Background Notification Tap (App Killed)

- When user taps the notification BODY (not action button) while app is killed, iOS launches the app normally. GoRouter redirect guard will navigate to Dashboard.
- When action button is tapped while app is killed, `onDidReceiveBackgroundNotificationResponse` fires in a background isolate. **Do not attempt UI navigation** from this context.
- For "Log 250ml" background action: write to Drift DB only, update widget data via `HomeWidget.saveWidgetData` and `HomeWidget.updateWidget`. Widget will reflect new data.

## 7.5 home_widget iOS Setup (WidgetKit)

- Requires Xcode Widget Extension target with separate bundle ID: `com.justdrink.app.JustDrinkWidget`.
- **App Group** is mandatory for data sharing between Runner and Widget. Both targets MUST have the same App Group ID (`group.com.justdrink.app`) in their entitlements.
- Data is shared via `UserDefaults(suiteName: "group.com.justdrink.app")`. Keys written by `HomeWidget.saveWidgetData` are prefixed with no prefix (unlike Android which prefixes with `flutter.`).
- `HomeWidget.setAppGroupId('group.com.justdrink.app')` must be called before any save/update calls on iOS.
- Widget buttons on iOS use `Link(destination: URL(string: "justdrink://log?amount=250")!)` in SwiftUI — NOT `Button`. Links are the only interactive elements in WidgetKit (no buttons, no tap gestures on arbitrary views).
- `WidgetCenter.shared.reloadAllTimelines()` must be called from the Swift side after the app writes data, OR via `HomeWidget.updateWidget(iOSName: 'JustDrinkWidget')` from Dart.
- The Flutter app must handle the URL scheme `justdrink://` in `AppDelegate.swift` via `application(_:open:options:)` AND `FlutterAppDelegate` passes it through as `HomeWidget.widgetClicked` stream.

## 7.6 home_widget Android Setup

- SharedPreferences keys on Android are prefixed: `HomeWidget.saveWidgetData('currentMl', 1250)` stores as key `flutter.currentMl` in the `FlutterSharedPreferences` prefs file.
- Read in Kotlin: `context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE).getInt("flutter.currentMl", 0)`.
- `AppWidgetProvider.onUpdate` is called by the Android system on a schedule. Set `updatePeriodMillis="0"` in `widget_info.xml` and always update manually via `AppWidgetManager.getInstance(context).updateAppWidget(...)` from the Dart side.
- Widget buttons use `PendingIntent` with `FLAG_IMMUTABLE` (required Android 12+): `PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)`.

## 7.7 Widget Data Sharing — Drift on iOS

- The Drift database file is in the Runner app's Documents directory. The Widget Extension **cannot access it directly** because of iOS sandbox restrictions.
- **Solution:** Use `HomeWidget.saveWidgetData` to write only the derived values (`currentMl`, `goalMl`, `progress`) needed by the widget. The widget reads from shared `UserDefaults` only — it never touches the SQLite file.
- This is the correct pattern: app writes to Drift → reads aggregated values → writes to shared UserDefaults → widget reads from UserDefaults.
- On Android, the same SharedPreferences approach applies. The widget never accesses the SQLite database directly.

## 7.8 in_app_purchase — Play Store vs App Store Differences

- **Play Store (Google Play Billing Library v5+):** Subscriptions are `ProductType.subs`. `buyNonConsumable` works for subscriptions. `completePurchase` is mandatory to acknowledge — unacknowledged purchases are refunded after 3 days.
- **App Store:** Subscriptions are also `buyNonConsumable`. iOS receipt is available in `PurchaseDetails.verificationData`. Local-only apps should call `completePurchase` and trust the platform.
- **Subscription Groups (App Store):** Both monthly and annual plans must be in the same subscription group in App Store Connect. Users can switch between them (upgrade/downgrade) without your app doing anything special.
- **Introductory Offers (Free Trial):** Set in App Store Connect as "Pay Nothing" for 7 days. Play Console: set "Free trial" period to 7 days in subscription configuration. These are platform-configured, not code-configured.
- **Restore Purchases (REQUIRED for App Store):** App Store review will reject apps without a "Restore Purchases" button. Implement `PurchaseService.restorePurchases()` → `InAppPurchase.instance.restorePurchases()`. Results arrive via `purchaseStream` with `PurchaseStatus.restored`.
- **Android Testing:** Use a `LICENSE_TEST` email in test accounts. Add email as a License Tester in Play Console. Use static product IDs in test builds.

## 7.9 Drift Cross-Platform Initialization

- Use `NativeDatabase.createInBackground(file)` for production. This runs the SQLite database on a background isolate, preventing UI jank.
- For tests: use `NativeDatabase.memory()` passed to `AppDatabase.forTesting(NativeDatabase.memory())`.
- On iOS, the database file must be in `getApplicationDocumentsDirectory()` (backed up to iCloud by default). If you don't want iCloud backup, use `getApplicationSupportDirectory()` and add `NSURLIsExcludedFromBackupResourceKey` attribute.
- Drift requires `sqlite3_flutter_libs` for Android and desktop. iOS uses the built-in SQLite. Ensure `sqlite3_flutter_libs` is in `dependencies` (not dev_dependencies).

## 7.10 Notification Permission Denial — Graceful Handling

- If user denies notification permission during onboarding, still navigate to Dashboard. The app is fully functional without notifications.
- In Settings, if `remindersEnabled = true` but actual system permission is denied, show a `ListTile` "Notifications are disabled in system settings" with a "Fix" button calling `openAppSettings()`.
- Check permission status every time `SettingsScreen` opens via `NotificationService.checkPermission()`.
- Never re-request permission automatically. Only show the OS dialog once (during onboarding). After that, always direct to OS settings.

## 7.11 Interstitial Ad Counter Persistence

- The `appLogCountToday` counter MUST persist across app restarts. An in-memory counter in `DashboardCubit` resets on every app restart allowing unlimited free logs.
- Store in `SharedPreferences` with keys `'ad_log_counter'` (int) and `'ad_log_counter_date'` (String, ISO date like `'2024-01-15'`).
- On every app launch, `DashboardCubit.initialize()` loads the counter from prefs and checks if the stored date == today. If different date, reset counter to 0.
- The counter only increments for `source = 'app'` logs (not widget logs). Widget logs are excluded from interstitial trigger.

---

# 8. COMPLETE pubspec.yaml

```yaml
name: justdrink
description: "JustDrink — Hyper-minimalist hydration tracker"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.6
  bloc: ^8.1.4
  equatable: ^2.0.5

  # Navigation
  go_router: ^14.3.0

  # Local Database
  drift: ^2.20.2
  sqlite3_flutter_libs: ^0.5.24
  path_provider: ^2.1.4
  path: ^1.9.0

  # Key-Value Storage
  shared_preferences: ^2.3.2

  # Notifications
  flutter_local_notifications: ^17.2.3
  timezone: ^0.9.4
  flutter_timezone: ^2.0.0

  # Home Screen Widget
  home_widget: ^0.7.0

  # Health Integration
  health: ^11.1.0

  # In-App Purchase
  in_app_purchase: ^3.2.0
  in_app_purchase_android: ^0.3.6
  in_app_purchase_storekit: ^0.3.17

  # Ads
  google_mobile_ads: ^5.1.0

  # Charts
  fl_chart: ^0.69.0

  # Fonts
  google_fonts: ^6.2.1

  # Utilities
  intl: ^0.19.0

  # DI
  get_it: ^8.0.2

  # App Settings (open OS settings page)
  app_settings: ^5.1.1

  # Icons
  flutter_svg: ^2.0.10+1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

  # Code generation for Drift
  drift_dev: ^2.20.2
  build_runner: ^2.4.12

  # Testing
  bloc_test: ^9.1.7
  mocktail: ^1.0.4

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/
  fonts:
    - family: Outfit
      fonts:
        - asset: assets/fonts/Outfit-Regular.ttf
        - asset: assets/fonts/Outfit-Medium.ttf
          weight: 500
        - asset: assets/fonts/Outfit-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Outfit-Bold.ttf
          weight: 700
```

> **Note on versions:** All versions above are the latest stable as of mid-2025. Always run `flutter pub outdated` after initial setup and upgrade patch versions as needed. Never upgrade major versions without checking changelogs for breaking changes.

> **Note on health package:** The `health` package v11+ requires Health Connect on Android (no longer Google Fit). Ensure `com.google.android.apps.healthdata` is listed in queries element in AndroidManifest. On iOS, add `NSHealthShareUsageDescription` to Info.plist. The health integration feature is scaffolded but can be shipped in v1.1.

---

# APPENDIX: HydrationCalculator Implementation

```dart
// lib/core/utils/hydration_calculator.dart

class HydrationCalculator {
  /// Calculates daily water intake goal in milliliters.
  ///
  /// Formula:
  ///   base = weightKg * 35 ml
  ///   age factor: <30 → +0%, 30-55 → -5%, >55 → -10%
  ///   gender factor: female → -10%, male/other → +0%
  ///   result rounded to nearest 50 ml
  ///   clamped to [1000, 5000] ml
  static int calculate({
    required double weightKg,
    required int age,
    required String gender, // 'male' | 'female' | 'other'
  }) {
    double base = weightKg * 35.0;

    // Age adjustment
    if (age >= 55) {
      base *= 0.90;
    } else if (age >= 30) {
      base *= 0.95;
    }

    // Gender adjustment
    if (gender == 'female') {
      base *= 0.90;
    }

    // Round to nearest 50
    int rounded = ((base / 50).round() * 50).toInt();

    // Clamp to safe range
    return rounded.clamp(1000, 5000);
  }
}
```

---

# APPENDIX: PreferencesService Full Implementation

```dart
// lib/data/preferences/preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  late SharedPreferences _prefs;

  static final PreferencesService instance = PreferencesService._();
  PreferencesService._();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool? getBool(String key) => _prefs.getBool(key);
  int? getInt(String key) => _prefs.getInt(key);
  String? getString(String key) => _prefs.getString(key);
  double? getDouble(String key) => _prefs.getDouble(key);

  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);
  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);
  Future<void> setString(String key, String value) => _prefs.setString(key, value);
  Future<void> setDouble(String key, double value) => _prefs.setDouble(key, value);

  Future<void> remove(String key) => _prefs.remove(key);
  Future<void> clear() => _prefs.clear();

  // ── Ad Counter with daily reset ──────────────────────────────────
  static const _adCounterKey     = 'ad_log_counter';
  static const _adCounterDateKey = 'ad_log_counter_date';

  Future<int> getAndIncrementAdCounter() async {
    final storedDate = getString(_adCounterDateKey);
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (storedDate != today) {
      // New day — reset counter
      await setString(_adCounterDateKey, today);
      await setInt(_adCounterKey, 1);
      return 1;
    }

    final current = getInt(_adCounterKey) ?? 0;
    final next = current + 1;
    await setInt(_adCounterKey, next);
    return next;
  }

  // ── Convenience keys ──────────────────────────────────────────────
  bool get isOnboardingComplete => getBool('onboarding_complete') ?? false;
  bool get isPremium => getBool('is_premium') ?? false;
  String? get premiumProductId => getString('premium_product_id');
  bool get notificationPermissionAsked => getBool('notification_permission_asked') ?? false;
}
```

---

# APPENDIX: main.dart Initialization Order

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get_it/get_it.dart';

import 'core/di/injection.dart';
import 'data/preferences/preferences_service.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/widget_service.dart';
import 'services/purchase_service.dart';
import 'services/ad_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Timezone (must be before notifications)
  tz.initializeTimeZones();
  final localTimezone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(localTimezone));

  // 2. SharedPreferences
  await PreferencesService.instance.initialize();

  // 3. Drift Database
  await DatabaseService.initialize();

  // 4. Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // 5. Widget Service
  final widgetService = WidgetService();
  await widgetService.initialize();

  // 6. Ad Service (init MobileAds SDK)
  final adService = AdService();
  await adService.initialize();

  // 7. Purchase Service (init stream listener)
  final purchaseService = PurchaseService();

  // 8. Register all with GetIt
  final sl = GetIt.instance;
  DatabaseService.registerWithGetIt(sl);
  sl.registerSingleton<NotificationService>(notificationService);
  sl.registerSingleton<WidgetService>(widgetService);
  sl.registerSingleton<AdService>(adService);
  sl.registerSingleton<PurchaseService>(purchaseService);
  sl.registerSingleton<PreferencesService>(PreferencesService.instance);

  runApp(const JustDrinkApp());
}
```
