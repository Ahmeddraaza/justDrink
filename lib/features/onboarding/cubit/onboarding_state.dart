import 'package:equatable/equatable.dart';

class OnboardingState extends Equatable {
  final int currentStep;
  final String gender;
  final double weightKg;
  final int age;
  final String unitPreference;
  final String wakeTime;
  final String sleepTime;
  final int calculatedGoalMl;
  final bool notificationPermissionGranted;
  final bool isLoading;
  final String? errorMessage;

  const OnboardingState({
    this.currentStep = 0,
    this.gender = 'male',
    this.weightKg = 70.0,
    this.age = 25,
    this.unitPreference = 'metric',
    this.wakeTime = '07:00',
    this.sleepTime = '23:00',
    this.calculatedGoalMl = 2500,
    this.notificationPermissionGranted = false,
    this.isLoading = false,
    this.errorMessage,
  });

  OnboardingState copyWith({
    int? currentStep,
    String? gender,
    double? weightKg,
    int? age,
    String? unitPreference,
    String? wakeTime,
    String? sleepTime,
    int? calculatedGoalMl,
    bool? notificationPermissionGranted,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      gender: gender ?? this.gender,
      weightKg: weightKg ?? this.weightKg,
      age: age ?? this.age,
      unitPreference: unitPreference ?? this.unitPreference,
      wakeTime: wakeTime ?? this.wakeTime,
      sleepTime: sleepTime ?? this.sleepTime,
      calculatedGoalMl: calculatedGoalMl ?? this.calculatedGoalMl,
      notificationPermissionGranted:
          notificationPermissionGranted ?? this.notificationPermissionGranted,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        gender,
        weightKg,
        age,
        unitPreference,
        wakeTime,
        sleepTime,
        calculatedGoalMl,
        notificationPermissionGranted,
        isLoading,
        errorMessage,
      ];
}
