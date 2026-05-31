import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/animated_waves.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/database/daos/water_log_dao.dart';
import '../../../data/database/daos/user_profile_dao.dart';
import '../../../data/preferences/preferences_service.dart';
import '../../../shared/cubits/ad/ad_cubit.dart';
import '../../../shared/cubits/widget_sync/widget_sync_cubit.dart';
import 'package:flutter/services.dart';
import '../../../shared/widgets/floating_navbar.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/widget_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DashboardCubit(
            waterLogDao: GetIt.I<WaterLogDao>(),
            userProfileDao: GetIt.I<UserProfileDao>(),
            preferencesService: GetIt.I<PreferencesService>(),
            adCubit: context.read<AdCubit>(),
            widgetSyncCubit: context.read<WidgetSyncCubit>(),
          )..initialize(),
        ),
      ],
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A365D),
        extendBody: true,
        bottomNavigationBar: const FloatingNavbar(activeRoute: Routes.dashboard),
        body: Stack(
          children: [
            // 0. Background Gradient
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1A365D), // Lighter premium navy
                      Color(0xFF2B6CB0), // Radiant blue
                    ],
                  ),
                ),
              ),
            ),
            // 1. Background Waves
            Positioned.fill(
              child: BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  final double percentage = (state.currentIntakeMl / state.dailyGoalMl).clamp(0.0, 1.0);
                  final double screenHeight = MediaQuery.of(context).size.height;
                  final double fillHeight = screenHeight * percentage;

                  return Stack(
                    children: [
                      AnimatedWaves(
                        height: fillHeight,
                        color: AppColors.wave1.withOpacity(0.4),
                        speed: 0.6,
                        offset: 0,
                      ),
                      AnimatedWaves(
                        height: fillHeight * 0.95,
                        color: AppColors.wave2.withOpacity(0.6),
                        speed: 0.9,
                        offset: 1.5,
                      ),
                      AnimatedWaves(
                        height: fillHeight * 0.9,
                        color: AppColors.wave3.withOpacity(0.8),
                        speed: 0.7,
                        offset: 3.0,
                      ),
                      AnimatedWaves(
                        height: fillHeight * 0.85,
                        color: AppColors.wave4,
                        speed: 1.1,
                        offset: 4.5,
                      ),
                    ],
                  );
                },
              ),
            ),

            // 2. Side Markers
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 100,
              child: BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  return Stack(
                    children: [
                      // Vertical Line
                      Positioned(
                        left: 24,
                        top: 150,
                        bottom: 150,
                        child: Container(
                          width: 1.5,
                          color: Colors.white24,
                        ),
                      ),
                      // Goal Marker (Static at the top)
                      _Marker(
                        label: '${state.dailyGoalMl}ML',
                        top: 150,
                        active: true,
                      ),
                      // Current Marker (Dynamic)
                      _DynamicMarker(
                        currentMl: state.currentIntakeMl,
                        goalMl: state.dailyGoalMl,
                      ),
                    ],
                  );
                },
              ),
            ),

            // 3. Main Content
            SafeArea(
              child: Column(
                children: [
                  // Top Bar (Centered Row design)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: SizedBox(
                      height: 48,
                      child: Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                                onPressed: () => context.push(Routes.settings),
                              ),
                            ),
                          ),
                          BlocBuilder<DashboardCubit, DashboardState>(
                            builder: (context, state) {
                              return Text(
                                '${state.dailyGoalMl}ML',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  fontSize: 16,
                                ),
                              );
                            },
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  BlocBuilder<DashboardCubit, DashboardState>(
                                    builder: (context, state) {
                                      if (state.isWidgetAdded) return const SizedBox.shrink();
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: TextButton(
                                          onPressed: () {
                                            if (state.isPremium) {
                                              _onAddWidget(context);
                                            } else {
                                              _showPremiumPopup(context, 'Home Screen Widget');
                                            }
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white24,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: Colors.white30),
                                            ),
                                            child: Text(
                                              '+ WIDGET',
                                              style: AppTextStyles.bodySmall.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 9,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  BlocBuilder<DashboardCubit, DashboardState>(
                                    builder: (context, state) {
                                      if (!state.isPremium) return const SizedBox.shrink();
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.workspace_premium_rounded, color: Colors.amber[200], size: 12),
                                            const SizedBox(width: 3),
                                            Text(
                                              'PRO',
                                              style: TextStyle(
                                                color: Colors.amber[200],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 9,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Percentage & Glasses
                  BlocBuilder<DashboardCubit, DashboardState>(
                    builder: (context, state) {
                      final int percentage = ((state.currentIntakeMl / state.dailyGoalMl) * 100).toInt();
                      final glasses = state.todayLogs.length;

                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$percentage',
                                style: GoogleFonts.roboto(
                                  fontSize: 100,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text(
                                  '%',
                                  style: GoogleFonts.roboto(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$glasses Glasses logged',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const Spacer(flex: 2),

                  // Add Button & Switch Cup
                  BlocBuilder<DashboardCubit, DashboardState>(
                    builder: (context, state) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 60), // Keeps main add button centered
                          GestureDetector(
                            onTap: () => context.read<DashboardCubit>().logWater(state.quickAdd1Ml),
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 25,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.local_drink_rounded,
                                  color: AppColors.wave3,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              if (state.isPremium) {
                                _showSwitchCupDialog(context, state);
                              } else {
                                _showPremiumPopup(context, 'Custom Cup Sizes');
                              }
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white30),
                                  ),
                                  child: const Icon(
                                    Icons.local_cafe_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.sync_rounded,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),

            // Undo Button
            Positioned(
              right: 24,
              bottom: 120,
              child: BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  if (!state.showUndo) return const SizedBox.shrink();
                  return FloatingActionButton.small(
                    onPressed: () => context.read<DashboardCubit>().undoLastLog(),
                    backgroundColor: Colors.white24,
                    child: const Icon(Icons.undo, color: Colors.white),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSwitchCupDialog(BuildContext context, DashboardState state) {
    final sizes = [100, 125, 150, 175, 200, 300, 400];
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          title: Text(
            'Select Cup Size',
            textAlign: TextAlign.center,
            style: AppTextStyles.h3.copyWith(color: AppColors.heading),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              SizedBox(
                width: double.maxFinite,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: sizes.length + 1,
                  itemBuilder: (gridCtx, index) {
                    if (index < sizes.length) {
                      final ml = sizes[index];
                      final isSelected = state.quickAdd1Ml == ml;

                      return GestureDetector(
                        onTap: () {
                          context.read<DashboardCubit>().updateCupSize(ml);
                          Navigator.pop(dialogContext);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withOpacity(0.12) : AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_drink_rounded,
                                color: isSelected ? AppColors.primary : AppColors.body,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$ml ml',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppColors.primary : AppColors.heading,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      final isCustomSelected = !sizes.contains(state.quickAdd1Ml);
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(dialogContext);
                          if (state.isPremium) {
                            _showCustomizeCupDialog(context, state);
                          } else {
                            _showPremiumPopup(context, 'Custom Log Volumes');
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCustomSelected ? AppColors.primary.withOpacity(0.12) : AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isCustomSelected ? AppColors.primary : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                color: isCustomSelected ? AppColors.primary : AppColors.body,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Custom',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isCustomSelected ? AppColors.primary : AppColors.heading,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.body,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCustomizeCupDialog(BuildContext context, DashboardState state) {
    final controller = TextEditingController(text: '${state.quickAdd1Ml}');
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text(
            'Custom Cup Size',
            textAlign: TextAlign.center,
            style: AppTextStyles.h3.copyWith(color: AppColors.heading),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  suffixText: 'ml',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.card),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.body)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final ml = int.tryParse(controller.text);
                    if (ml != null && ml > 0) {
                      context.read<DashboardCubit>().updateCupSize(ml);
                      Navigator.pop(dialogContext);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _onAddWidget(BuildContext context) async {
    context.read<DashboardCubit>().markWidgetAdded();

    try {
      final widgetService = GetIt.I<WidgetService>();
      await widgetService.requestPinWidget();

      if (Theme.of(context).platform == TargetPlatform.iOS) {
        if (context.mounted) {
          _showIOSWidgetGuide(context);
        }
      }
    } catch (e) {
      debugPrint('Error pinning widget: $e');
    }
  }

  void _showIOSWidgetGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text('Add Widget to Home Screen', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            _GuideStep(number: '1', text: 'Go to your Home Screen and long press on any empty area.'),
            _GuideStep(number: '2', text: 'Tap the (+) button in the top left corner.'),
            _GuideStep(number: '3', text: 'Search for "JustDrink" and select your preferred widget size.'),
            _GuideStep(number: '4', text: 'Tap "Add Widget" to place it on your screen.'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dashboardBackground,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('GOT IT'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  void _showPremiumPopup(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.workspace_premium_outlined, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Text('Premium', style: AppTextStyles.h3),
            ],
          ),
          content: Text(
            '$featureName is a Premium feature. Unlock the full potential of JustDrink by subscribing!',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Maybe Later', style: TextStyle(color: AppColors.body)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                context.push(Routes.paywall);
              },
              child: const Text('Subscribe', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

class _GuideStep extends StatelessWidget {
  final String number;
  final String text;
  const _GuideStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(text, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.body)),
          ),
        ],
      ),
    );
  }
}

class _Marker extends StatelessWidget {
  final String label;
  final double top;
  final bool active;

  const _Marker({
    required this.label,
    required this.top,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: top,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 1.5,
            color: active ? Colors.white : Colors.white24,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.white24,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DynamicMarker extends StatelessWidget {
  final int currentMl;
  final int goalMl;

  const _DynamicMarker({
    required this.currentMl,
    required this.goalMl,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show the dynamic marker if it's empty or exactly at the goal (to avoid overlapping text)
    if (currentMl <= 0 || currentMl == goalMl) return const SizedBox.shrink();
    
    final double percentage = (currentMl / goalMl).clamp(0.0, 1.0);
    final double screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate top position
    final double top = (screenHeight - 300) * (1 - percentage) + 150;

    // Additional safety check: if the marker is too close to the goal (top: 150), don't show it
    if (top < 170) return const SizedBox.shrink();

    return _Marker(
      label: '${currentMl}ML',
      top: top,
      active: true,
    );
  }
}
