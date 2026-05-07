import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart';

import 'settings_state.dart';
import '../../../data/database/daos/user_profile_dao.dart';
import '../../../services/notification_service.dart';
import '../../../data/preferences/preferences_service.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final UserProfileDao userProfileDao;
  final NotificationService notificationService;
  final PreferencesService preferencesService;

  StreamSubscription? _profileSubscription;

  SettingsCubit({
    required this.userProfileDao,
    required this.notificationService,
    required this.preferencesService,
  }) : super(const SettingsState());

  void initialize() {
    _profileSubscription = userProfileDao.watchProfile().listen((profile) {
      if (profile != null) {
        emit(state.copyWith(
          profile: profile,
          isPremium: profile.isPremium,
        ));
      }
    });
  }

  Future<void> updateGoal(int goalMl) async {
    await userProfileDao.updateDailyGoal(goalMl);
  }

  Future<void> updateWeight(double weightKg) async {
    await userProfileDao.updateWeight(weightKg);
  }

  Future<void> toggleReminders(bool enabled) async {
    await userProfileDao.updateRemindersEnabled(enabled);
    if (state.profile != null) {
      if (enabled) {
        await notificationService.rescheduleAll(state.profile!);
      } else {
        await notificationService.cancelAll();
      }
    }
  }

  Future<void> updateReminderCount(int count) async {
    await userProfileDao.updateReminderCount(count);
    if (state.profile != null) {
      await notificationService.rescheduleAll(state.profile!.copyWith(reminderCount: count));
    }
  }

  Future<void> updateCustomNotifText(String text) async {
    await userProfileDao.updateCustomNotificationText(text);
    if (state.profile != null) {
      await notificationService.rescheduleAll(state.profile!.copyWith(customNotificationText: Value(text)));
    }

  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}
