import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import 'core/constants/route_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/preferences/preferences_service.dart';
import 'features/onboarding/cubit/onboarding_cubit.dart';
import 'shared/cubits/ad/ad_cubit.dart';
import 'shared/cubits/notification/notification_cubit.dart';
import 'shared/cubits/widget_sync/widget_sync_cubit.dart';
import 'services/ad_service.dart';
import 'services/notification_service.dart';
import 'services/widget_service.dart';
import 'data/database/daos/water_log_dao.dart';
import 'data/database/daos/user_profile_dao.dart';



// Screens - Placeholder stubs for now to avoid compilation errors
import 'features/splash/screens/splash_screen.dart';
import 'features/onboarding/screens/onboarding_intro_screen.dart';
import 'features/onboarding/screens/onboarding_step1_screen.dart';
import 'features/onboarding/screens/onboarding_step2_screen.dart';
import 'features/onboarding/screens/onboarding_step3_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/history/screens/history_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/paywall/screens/paywall_screen.dart';
import 'features/settings/screens/custom_volume_edit_screen.dart';
import 'features/settings/screens/custom_notification_text_screen.dart';

class JustDrinkApp extends StatelessWidget {
  const JustDrinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AdCubit(adService: GetIt.I<AdService>())
            ..initialize(GetIt.I<PreferencesService>().isPremium),
        ),
        BlocProvider(
          create: (context) => NotificationCubit(
            notificationService: GetIt.I<NotificationService>(),
          )..checkPermissionStatus(),
        ),
        BlocProvider(
          create: (context) => WidgetSyncCubit(
            widgetService: GetIt.I<WidgetService>(),
            waterLogDao: GetIt.I<WaterLogDao>(),
            userProfileDao: GetIt.I<UserProfileDao>(),
          )..sync(),
        ),
      ],
      child: MaterialApp.router(
        title: 'JustDrink',
        theme: AppTheme.lightTheme,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}


final _router = GoRouter(
  initialLocation: Routes.splash,
  redirect: (context, state) async {
    final prefs = GetIt.I<PreferencesService>();
    final onboarded = prefs.isOnboardingComplete;
    
    final isOnboarding = state.uri.path.startsWith('/onboarding');
    final isSplash = state.uri.path == Routes.splash;

    if (!onboarded && !isOnboarding && !isSplash) {
      return Routes.onboardingIntro;
    }

    return null;
  },
  routes: [
    GoRoute(path: Routes.splash,          builder: (c,s) => const SplashScreen()),
    GoRoute(
        path: Routes.onboardingIntro,
        builder: (c, s) => const OnboardingIntroScreen()),
    GoRoute(
        path: Routes.onboardingStep1,
        builder: (c, s) => const OnboardingStep1Screen()),

    GoRoute(
        path: Routes.onboardingStep2,
        builder: (c, s) => OnboardingStep2Screen(cubit: s.extra as OnboardingCubit)),
    GoRoute(
        path: Routes.onboardingStep3,
        builder: (c, s) => OnboardingStep3Screen(cubit: s.extra as OnboardingCubit)),

    GoRoute(path: Routes.dashboard,       builder: (c,s) => const DashboardScreen()),
    GoRoute(path: Routes.history,         builder: (c,s) => const HistoryScreen()),
    GoRoute(path: Routes.settings,        builder: (c,s) => const SettingsScreen()),
    GoRoute(path: Routes.paywall,         builder: (c,s) => const PaywallScreen()),
    GoRoute(path: Routes.customVolume,    builder: (c,s) => const CustomVolumeEditScreen()),
    GoRoute(path: Routes.customNotifText, builder: (c,s) => const CustomNotificationTextScreen()),
  ],
);
