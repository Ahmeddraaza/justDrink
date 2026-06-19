import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Log when user successfully completes onboarding
  static Future<void> logOnboardingComplete() async {
    await _analytics.logEvent(
      name: 'onboarding_complete',
    );
  }

  /// Log when a user adds a water log
  static Future<void> logAddWater({required int amountMl}) async {
    await _analytics.logEvent(
      name: 'add_water',
      parameters: {'amount_ml': amountMl},
    );
  }
}
