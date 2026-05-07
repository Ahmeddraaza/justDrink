import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart';
import 'onboarding_state.dart';
import '../../../core/utils/hydration_calculator.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/daos/user_profile_dao.dart';
import '../../../services/notification_service.dart';
import '../../../services/widget_service.dart';
import '../../../data/preferences/preferences_service.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final UserProfileDao userProfileDao;
  final NotificationService notificationService;
  final WidgetService widgetService;
  final PreferencesService preferencesService;

  OnboardingCubit({
    required this.userProfileDao,
    required this.notificationService,
    required this.widgetService,
    required this.preferencesService,
  }) : super(const OnboardingState());

  void setGender(String gender) {
    emit(state.copyWith(gender: gender));
    _recalculateGoal();
  }

  void setWeight(double weight) {
    double weightKg = weight;
    if (state.unitPreference == 'imperial') {
      weightKg = weight * 0.453592; // lbs to kg
    }
    emit(state.copyWith(weightKg: weightKg));
    _recalculateGoal();
  }

  void setAge(int age) {
    emit(state.copyWith(age: age));
    _recalculateGoal();
  }

  void toggleUnit() {
    final newUnit = state.unitPreference == 'metric' ? 'imperial' : 'metric';
    emit(state.copyWith(unitPreference: newUnit));
  }

  void setWakeTime(String time) {
    emit(state.copyWith(wakeTime: time));
  }

  void setSleepTime(String time) {
    emit(state.copyWith(sleepTime: time));
  }

  void _recalculateGoal() {
    final goal = HydrationCalculator.calculate(
      weightKg: state.weightKg,
      age: state.age,
      gender: state.gender,
    );
    emit(state.copyWith(calculatedGoalMl: goal));
  }

  Future<void> requestNotificationPermission() async {
    final granted = await notificationService.requestPermission();
    emit(state.copyWith(notificationPermissionGranted: granted));
  }

  Future<void> completeOnboarding() async {
    emit(state.copyWith(isLoading: true));
    try {
      final profile = UserProfileCompanion(
        id: const Value(1),
        gender: Value(state.gender),
        weightKg: Value(state.weightKg),
        age: Value(state.age),
        unitPreference: Value(state.unitPreference),
        dailyGoalMl: Value(state.calculatedGoalMl),
        wakeTime: Value(state.wakeTime),
        sleepTime: Value(state.sleepTime),
        onboardingComplete: const Value(true),
      );

      await userProfileDao.upsertProfile(profile);
      
      final profileData = await userProfileDao.getProfile();
      if (profileData != null) {
        await notificationService.rescheduleAll(profileData);
        await widgetService.updateWidget(
          currentMl: 0,
          goalMl: state.calculatedGoalMl,
          isPremium: false,
        );
      }
      
      await preferencesService.setBool('onboarding_complete', true);
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void nextStep() {
    emit(state.copyWith(currentStep: state.currentStep + 1));
  }
}
