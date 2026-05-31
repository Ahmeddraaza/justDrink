import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Log when user successfully completes onboarding
  static Future<void> logOnboardingComplete() async {
    await _analytics.logEvent(
      name: 'onboarding_complete',
    );
  }

  /// Log when the subscription paywall screen is opened
  static Future<void> logViewSubscription() async {
    await _analytics.logEvent(
      name: 'view_subscription',
    );
  }

  /// Log when the user clicks 'Subscribe Now'
  static Future<void> logClickSubscribe({required String planId}) async {
    await _analytics.logEvent(
      name: 'click_subscribe',
      parameters: {'plan_id': planId},
    );
  }

  /// Log when a premium purchase is successfully completed
  static Future<void> logPurchaseSuccess({required String planId}) async {
    await _analytics.logEvent(
      name: 'purchase_success',
      parameters: {'plan_id': planId},
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
