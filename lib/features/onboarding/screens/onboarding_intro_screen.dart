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
    if (_currentPage < 3) {
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
      resizeToAvoidBottomInset: false,
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        GestureDetector(
                          onTap: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                            );
                          },
                          child: const Icon(Icons.arrow_back_ios, color: AppColors.heading, size: 20),
                        )
                      else
                        const SizedBox(width: 20),
                      TextButton(
                        onPressed: () {
                          context.read<OnboardingCubit>().completeOnboarding().then((_) {
                            context.go(Routes.dashboard);
                          });
                        },
                        child: Text('Skip', style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
                // "Personal hydration plan" badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.transparent,
                      backgroundImage: AssetImage('assets/images/boyWaterdrink.png'), // Or an appropriate icon
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Personal hydration plan',
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Main Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildPage1(state),
                      _buildPage2(state),
                      _buildPageSleepWake(state),
                      _buildPage3(state),
                    ],
                  ),
                ),
                // Footer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  child: Column(
                    children: [
                      // Dot Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) => _buildDot(index)),
                      ),
                      const SizedBox(height: 16),
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
                                  _currentPage == 3 ? 'GET STARTED' : 'NEXT',
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
          const SizedBox(height: 16),
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
          const SizedBox(height: 12),
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

  Widget _buildPageSleepWake(OnboardingState state) {
    return _BasePage(
      imagePath: 'assets/images/waterbottle.png',
      title: 'Your Schedule',
      subtitle: 'Set your sleep and wake up times for reminders.',
      extra: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TimePickerTile(
                  label: 'Wake Up',
                  time: state.wakeTime,
                  icon: Icons.wb_sunny_rounded,
                  onTap: () => _showTimePicker(context, true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _TimePickerTile(
                  label: 'Sleep',
                  time: state.sleepTime,
                  icon: Icons.nights_stay_rounded,
                  onTap: () => _showTimePicker(context, false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPage3(OnboardingState state) {
    final int times = 10;
    final int amountPerTime = (state.calculatedGoalMl / times).round();

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
          // Glass with Badge Graphic
          GestureDetector(
            onTap: () => _showEditTargetDialog(context, state.calculatedGoalMl),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // The Glass Outline
                Container(
                  width: 110,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 8),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  alignment: Alignment.bottomCenter,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 110),
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Container(
                        height: value,
                        margin: const EdgeInsets.all(4),
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${amountPerTime}ml',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // "x10" Badge
                Positioned(
                  top: -30,
                  right: -50,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Left Ear
                            Positioned(
                              top: 0,
                              left: 10,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            // Right Ear
                            Positioned(
                              top: 0,
                              right: 10,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            // Main Badge Circle
                            Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(top: 10),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'x$times',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'How much should you drink',
            style: AppTextStyles.h1.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Target: ${state.calculatedGoalMl} ml / day',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$times times a day\n$amountPerTime ml each time',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.grey.shade600,
              fontSize: 16,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _showEditTargetDialog(context, state.calculatedGoalMl),
            icon: const Icon(Icons.edit, color: Colors.grey, size: 16),
            label: const Text('Edit Target', style: TextStyle(color: Colors.grey)),
          )
        ],
      ),
    ));
  }

  Future<void> _showEditTargetDialog(BuildContext context, int currentGoal) async {
    final controller = TextEditingController(text: currentGoal.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Edit Daily Goal (ml)'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: 'e.g. 2500',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final val = int.tryParse(controller.text);
                Navigator.pop(context, val);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (result != null && mounted) {
      context.read<OnboardingCubit>().setCalculatedGoalMl(result);
    }
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
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
            Image.asset(imagePath, height: 180, fit: BoxFit.contain),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.h2.copyWith(color: AppColors.heading, fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
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
  final IconData icon;
  final VoidCallback onTap;

  const _TimePickerTile({
    required this.label,
    required this.time,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.heading)),
            const SizedBox(height: 4),
            Text(time, style: AppTextStyles.h2.copyWith(fontSize: 22, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
