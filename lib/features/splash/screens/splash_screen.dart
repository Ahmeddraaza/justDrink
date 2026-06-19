import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/preferences/preferences_service.dart';
import '../../../data/database/daos/user_profile_dao.dart';
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
    if (!mounted) return;

    // ── STEP 1: Google UMP / CMP Consent Form ─────────────────────────────────
    // This shows the GDPR consent dialog (as seen in the screenshot) for EEA/UK
    // users. For non-EEA users it completes immediately.
    // IMPORTANT: Must run BEFORE MobileAds.initialize() per Google policy.
    await _requestUmpConsent();
    if (!mounted) return;

    // ── STEP 2: Initialize MobileAds SDK ──────────────────────────────────────
    // ATT is handled in main() before NotificationService starts (ensures ATT
    // fires before notification permission on every fresh install).
    // UMP consent (Step 1 above) is done — safe to initialize AdMob now.
    try {
      await MobileAds.instance.initialize();
      debugPrint('[Splash] MobileAds SDK initialized after consent.');
    } catch (e) {
      debugPrint('[Splash] MobileAds init failed: $e');
    }
    if (!mounted) return;

    // ── STEP 4: Load user profile & start ad loading ──────────────────────────
    final prefs = GetIt.I<PreferencesService>();
    final adCubit = context.read<AdCubit>(); // cache before async gap
    final profile = await GetIt.I<UserProfileDao>().getProfile();
    final isPremium = profile?.isPremium ?? false;

    // AdCubit.initialize now only loads ads (SDK already initialized above)
    adCubit.initialize(isPremium);

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

  /// Requests UMP consent info and shows the CMP form if required.
  /// Completes immediately for non-EEA/UK users (form not available).
  Future<void> _requestUmpConsent() async {
    final completer = Completer<void>();

    try {
      final params = ConsentRequestParameters();

      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          // Success callback — check if a form needs to be shown
          try {
            final formAvailable =
                await ConsentInformation.instance.isConsentFormAvailable();
            if (formAvailable) {
              if (!mounted) {
                completer.complete();
                return;
              }
              ConsentForm.loadAndShowConsentFormIfRequired(
                (FormError? formError) {
                  if (formError != null) {
                    debugPrint(
                        '[UMP] Form error: ${formError.errorCode} — ${formError.message}');
                  }
                  completer.complete();
                },
              );
            } else {
              // No form required (non-EEA user or already consented)
              debugPrint('[UMP] Consent form not available — skipping.');
              completer.complete();
            }
          } catch (e) {
            debugPrint('[UMP] Error checking/loading form: $e');
            completer.complete();
          }
        },
        (FormError error) {
          debugPrint(
              '[UMP] requestConsentInfoUpdate failed: ${error.message}');
          completer.complete();
        },
      );

      await completer.future;
    } catch (e) {
      debugPrint('[UMP] Unexpected error: $e');
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
                  'assets/icons/icon.svg',
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
