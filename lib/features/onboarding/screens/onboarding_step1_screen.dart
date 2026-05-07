import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/database/daos/user_profile_dao.dart';
import '../../../services/notification_service.dart';
import '../../../services/widget_service.dart';
import '../../../data/preferences/preferences_service.dart';

class OnboardingStep1Screen extends StatelessWidget {
  const OnboardingStep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingCubit(
        userProfileDao: GetIt.I<UserProfileDao>(),
        notificationService: GetIt.I<NotificationService>(),
        widgetService: GetIt.I<WidgetService>(),
        preferencesService: GetIt.I<PreferencesService>(),
      ),
      child: const _OnboardingStep1View(),
    );
  }
}

class _OnboardingStep1View extends StatefulWidget {
  const _OnboardingStep1View();

  @override
  State<_OnboardingStep1View> createState() => _OnboardingStep1ViewState();
}

class _OnboardingStep1ViewState extends State<_OnboardingStep1View> {
  final _weightController = TextEditingController(text: '70');
  final _ageController = TextEditingController(text: '25');

  @override
  void dispose() {
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const SizedBox(height: 40),
              Text(
                "Let's calculate your daily goal.",
                style: AppTextStyles.h2.copyWith(color: AppColors.heading),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),
              // Gender Selector
              BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) {
                  return SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'male', label: Text('Male')),
                      ButtonSegment(value: 'female', label: Text('Female')),
                      ButtonSegment(value: 'other', label: Text('Other')),
                    ],
                    selected: {state.gender},
                    onSelectionChanged: (val) =>
                        context.read<OnboardingCubit>().setGender(val.first),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Weight Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Weight',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        final d = double.tryParse(val);
                        if (d != null) {
                          context.read<OnboardingCubit>().setWeight(d);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  BlocBuilder<OnboardingCubit, OnboardingState>(
                    builder: (context, state) {
                      return ToggleButtons(
                        isSelected: [
                          state.unitPreference == 'metric',
                          state.unitPreference == 'imperial'
                        ],
                        onPressed: (index) =>
                            context.read<OnboardingCubit>().toggleUnit(),
                        children: const [
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('kg')),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('lbs')),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Age Input
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  final i = int.tryParse(val);
                  if (i != null) {
                    context.read<OnboardingCubit>().setAge(i);
                  }
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.push(Routes.onboardingStep2,
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
