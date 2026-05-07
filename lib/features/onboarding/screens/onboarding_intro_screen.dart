import 'package:flutter/cupertino.dart';
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

class OnboardingIntroScreen extends StatelessWidget {
  const OnboardingIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingCubit(
        userProfileDao: GetIt.I<UserProfileDao>(),
        notificationService: GetIt.I<NotificationService>(),
        widgetService: GetIt.I<WidgetService>(),
        preferencesService: GetIt.I<PreferencesService>(),
      ),
      child: const _OnboardingIntroView(),
    );
  }
}

class _OnboardingIntroView extends StatefulWidget {
  const _OnboardingIntroView();

  @override
  State<_OnboardingIntroView> createState() => _OnboardingIntroViewState();
}

class _OnboardingIntroViewState extends State<_OnboardingIntroView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.read<OnboardingCubit>().completeOnboarding().then((_) {
        context.go(Routes.dashboard);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                            );
                          },
                        ),
                      const Spacer(),
                    ],
                  ),
                ),
                // Main Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildPage1(state),
                      _buildPage2(state),
                      _buildPage3(state),
                    ],
                  ),
                ),
                // Footer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Column(
                    children: [
                      // Dot Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) => _buildDot(index)),
                      ),
                      const SizedBox(height: 32),
                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: state.isLoading ? null : _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: state.isLoading
                              ? const CupertinoActivityIndicator(color: Colors.white)
                              : Text(
                                  _currentPage == 2 ? 'GET STARTED' : 'NEXT',
                                  style: AppTextStyles.button.copyWith(
                                    color: Colors.white,
                                    fontSize: 18,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildPage1(OnboardingState state) {
    return _BasePage(
      imagePath: 'assets/images/womenWaterdrink.png',
      title: 'Track your daily water intake with Us.',
      subtitle: 'Achieve your hydration goals with a simple tap!',
      extra: Column(
        children: [
          const SizedBox(height: 32),
          Text('Select Gender', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'male', label: Text('Male')),
              ButtonSegment(value: 'female', label: Text('Female')),
              ButtonSegment(value: 'other', label: Text('Other')),
            ],
            selected: {state.gender},
            onSelectionChanged: (val) => context.read<OnboardingCubit>().setGender(val.first),
          ),
        ],
      ),
    );
  }

  Widget _buildPage2(OnboardingState state) {
    return _BasePage(
      imagePath: 'assets/images/boyWaterdrink.png',
      title: 'Personalize Your Plan',
      subtitle: 'We use your weight and age to calculate your baseline goal.',
      extra: Column(
        children: [
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PickerColumn(
                label: 'Weight (${state.unitPreference == 'metric' ? 'kg' : 'lbs'})',
                value: state.weightKg.round(),
                minValue: 30,
                maxValue: 200,
                onChanged: (val) => context.read<OnboardingCubit>().setWeight(val.toDouble()),
              ),
              const SizedBox(width: 24),
              _PickerColumn(
                label: 'Age',
                value: state.age,
                minValue: 5,
                maxValue: 100,
                onChanged: (val) => context.read<OnboardingCubit>().setAge(val),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPage3(OnboardingState state) {
    return _BasePage(
      imagePath: 'assets/images/waterbottle.png',
      title: 'Easy to Use – Drink, Tap, Repeat',
      subtitle: 'Set your schedule and we\'ll remind you at the perfect intervals.',
      extra: Column(
        children: [
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _TimePickerTile(
                  label: 'Wake Up',
                  time: state.wakeTime,
                  onTap: () => _showTimePicker(context, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimePickerTile(
                  label: 'Sleep',
                  time: state.sleepTime,
                  onTap: () => _showTimePicker(context, false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Target: ${state.calculatedGoalMl}ml / day',
              style: AppTextStyles.h2.copyWith(color: AppColors.primary, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTimePicker(BuildContext context, bool isWake) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isWake ? const TimeOfDay(hour: 7, minute: 0) : const TimeOfDay(hour: 23, minute: 0),
    );
    if (time != null && mounted) {
      final formatted = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      if (isWake) {
        context.read<OnboardingCubit>().setWakeTime(formatted);
      } else {
        context.read<OnboardingCubit>().setSleepTime(formatted);
      }
    }
  }
}

class _BasePage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final Widget extra;

  const _BasePage({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Image.asset(imagePath, height: 200, fit: BoxFit.contain),
            const SizedBox(height: 32),
            Text(
              title,
              style: AppTextStyles.h2.copyWith(color: AppColors.heading, fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.body),
              textAlign: TextAlign.center,
            ),
            extra,
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _PickerColumn extends StatelessWidget {
  final String label;
  final int value;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;

  const _PickerColumn({
    required this.label,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          width: 80,
          child: CupertinoPicker(
            itemExtent: 40,
            scrollController: FixedExtentScrollController(initialItem: value - minValue),
            onSelectedItemChanged: (index) => onChanged(index + minValue),
            children: List.generate(
              maxValue - minValue + 1,
              (index) => Center(
                child: Text(
                  '${index + minValue}',
                  style: AppTextStyles.h2.copyWith(fontSize: 22, color: AppColors.primary),
                ),
              ),
            ),
          ),
        ),
      ],
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(label, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(time, style: AppTextStyles.h2.copyWith(fontSize: 20, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
