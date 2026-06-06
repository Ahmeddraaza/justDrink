import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/preferences/preferences_service.dart';
import '../../../data/database/daos/user_profile_dao.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../shared/cubits/ad/ad_cubit.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _navigateToNext();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNext() async {
    // Wait for the first frame to render before showing prompts
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 1. Google UMP Consent for EEA/UK
    try {
      final params = ConsentRequestParameters();
      await ConsentInformation.instance.requestConsentInfoUpdate(params);
      if (await ConsentInformation.instance.isConsentFormAvailable()) {
        await ConsentForm.loadAndShowConsentFormIfRequired();
      }
    } catch (e) {
      debugPrint('UMP consent request failed: $e');
    }

    // 2. Apple ATT Prompt
    try {
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        final status = await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          await AppTrackingTransparency.requestTrackingAuthorization();
        }
      }
    } catch (e) {
      debugPrint('ATT request failed: $e');
    }

    if (!mounted) return;
    final prefs = GetIt.I<PreferencesService>();
    final profile = await GetIt.I<UserProfileDao>().getProfile();
    final isPremium = profile?.isPremium ?? false;

    // Initialize AdCubit AFTER ATT prompt is handled
    context.read<AdCubit>().initialize(isPremium);

    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    if (!prefs.isOnboardingComplete) {
      context.go(Routes.onboardingIntro);
    } else {
      if (!isPremium) {
        context.go(Routes.paywall);
      } else {
        context.go(Routes.dashboard);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: Stack(
        children: [
          // Bottom Waves
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/waves.png',
              fit: BoxFit.cover,
            ),
          ),
          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 // Logo
                Image.asset(
                  'assets/images/logoicon.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  'Just Drink',
                  style: AppTextStyles.h1.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    'Stay hydrated and track your daily water intake',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Loading Indicator (Represented as three dots)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final double delay = index * 0.15;
                    return _JumpingDot(
                      animation: CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          delay,
                          (delay + 0.65).clamp(0.0, 1.0),
                          curve: const _BounceCurve(),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BounceCurve extends Curve {
  const _BounceCurve();

  @override
  double transform(double t) {
    return math.sin(t * math.pi);
  }
}

class _JumpingDot extends StatelessWidget {
  final Animation<double> animation;

  const _JumpingDot({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -14 * animation.value),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
