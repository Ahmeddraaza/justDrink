import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class OnboardingStep3Screen extends StatelessWidget {
  final OnboardingCubit cubit;
  const OnboardingStep3Screen({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: const _OnboardingStep3View(),
    );
  }
}

class _OnboardingStep3View extends StatelessWidget {
  const _OnboardingStep3View();

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
                "Your Daily Goal",
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      Text(
                        "${state.calculatedGoalMl}",
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 64,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        "ml",
                        style: AppTextStyles.h2.copyWith(color: Colors.white70),
                      ),
                    ],
                  );
                },
              ),
              const Spacer(),
              Text(
                "Hydration plan is ready. Allow notifications for your reminders.",
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              BlocConsumer<OnboardingCubit, OnboardingState>(
                listener: (context, state) {
                  if (state.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMessage!)),
                    );
                  }
                  if (!state.isLoading && state.currentStep == 0 && state.errorMessage == null) {
                    // Logic for completion handled by cubit, then navigate
                  }
                },
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () async {
                            final cubit = context.read<OnboardingCubit>();
                            await cubit.requestNotificationPermission();
                            await cubit.completeOnboarding();
                            if (context.mounted) {
                              context.go(Routes.dashboard);
                            }
                          },
                    child: state.isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text('Start Reminders'),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
