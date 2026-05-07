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
