import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class OnboardingStep2Screen extends StatelessWidget {
  final OnboardingCubit cubit;
  const OnboardingStep2Screen({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: const _OnboardingStep2View(),
    );
  }
}

class _OnboardingStep2View extends StatelessWidget {
  const _OnboardingStep2View();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, Color(0xFF162A49)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                "YOUR TIME",
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Wake & Sleep — This bounds your reminders.",
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              // Wake Up Picker
              BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) {
                  return _TimePickerTile(
                    label: 'Wake Up',
                    time: state.wakeTime,
                    onTap: () async {
                      final parts = state.wakeTime.split(':');
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                            hour: int.parse(parts[0]),
                            minute: int.parse(parts[1])),
                      );
                      if (time != null && context.mounted) {
                        context.read<OnboardingCubit>().setWakeTime(
                            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              // Sleep Picker
              BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) {
                  return _TimePickerTile(
                    label: 'Bed Time',
                    time: state.sleepTime,
                    onTap: () async {
                      final parts = state.sleepTime.split(':');
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                            hour: int.parse(parts[0]),
                            minute: int.parse(parts[1])),
                      );
                      if (time != null && context.mounted) {
                        context.read<OnboardingCubit>().setSleepTime(
                            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
                      }
                    },
                  );
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.push(Routes.onboardingStep3,
                    extra: context.read<OnboardingCubit>()),
                child: const Text('Next'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimePickerTile extends StatelessWidget {
  final String label;
  final String time;
  final VoidCallback onTap;

  const _TimePickerTile({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodyMedium),
            Text(time,
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
