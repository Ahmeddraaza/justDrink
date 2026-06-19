import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

import 'data/preferences/preferences_service.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/widget_service.dart';
import 'services/purchase_service.dart';
import 'services/ad_service.dart';
import 'data/database/daos/user_profile_dao.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    tz.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone().timeout(const Duration(seconds: 2));
    tz.setLocalLocation(tz.getLocation(localTimezone.identifier));
  } catch (e) {
    tz.setLocalLocation(tz.getLocation('UTC'));
  }

  await PreferencesService.instance.initialize();

  await DatabaseService.initialize();

  // ── ATT Pre-flight (iOS only) ────────────────────────────────────────────
  // MUST run before NotificationService.initialize() because flutter_local_
  // notifications triggers the iOS notification permission request during its
  // own initialize() call. If notification permission fires first, ATT gets
  // pushed to the NEXT app launch (the bug). Running ATT here, synchronously
  // in main(), guarantees it always appears FIRST on fresh installs.
  if (Platform.isIOS) {
    try {
      // Wait for the engine to be ready before showing a system dialog.
      await Future.delayed(const Duration(milliseconds: 200));
      final attStatus =
          await AppTrackingTransparency.trackingAuthorizationStatus;
      if (attStatus == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
      debugPrint('[main] ATT status: $attStatus');
    } catch (e) {
      debugPrint('[main] ATT pre-flight failed: $e');
    }
  }

  final notificationService = NotificationService();
  try {
    await notificationService.initialize().timeout(const Duration(seconds: 5));
  } catch (e) {
    debugPrint('Notification init failed: $e');
  }

  final widgetService = WidgetService();
  await widgetService.initialize();

  final adService = AdService();
  try {
    await adService.initialize().timeout(const Duration(seconds: 3));
  } catch (e) {
    debugPrint('Ad service init failed: $e');
  }

  final purchaseService = PurchaseService();
  try {
    await purchaseService.initialize().timeout(const Duration(seconds: 3));
  } catch (e) {
    debugPrint('Purchase service init failed: $e');
  }

  final sl = GetIt.instance;
  DatabaseService.registerWithGetIt(sl);
  sl.registerSingleton<NotificationService>(notificationService);
  sl.registerSingleton<WidgetService>(widgetService);
  sl.registerSingleton<AdService>(adService);
  sl.registerSingleton<PurchaseService>(purchaseService);
  sl.registerSingleton<PreferencesService>(PreferencesService.instance);

  // Verifies and auto-expires premium if active subscription ended
  try {
    final purchaseService = sl<PurchaseService>();
    await purchaseService.checkExistingPremium();
  } catch (e) {
    debugPrint('Failed to check existing premium on launch: $e');
  }

  // Healing check for premium status (migrates old profiles created with isPremium=true by default)
  try {
    final userProfileDao = sl<UserProfileDao>();
    final profile = await userProfileDao.getProfile();
    if (profile != null && profile.isPremium && (profile.premiumProductId == null || profile.premiumProductId!.isEmpty)) {
      await userProfileDao.updatePremiumStatus(isPremium: false);
      await PreferencesService.instance.setBool('is_premium', false);
      
      // Update widget state to reflect locked status
      await widgetService.updateWidget(
        currentMl: 0,
        goalMl: profile.dailyGoalMl,
        isPremium: false,
      );
    }
  } catch (e) {
    debugPrint('Failed to run premium status healing check: $e');
  }

  runApp(const JustDrinkApp());
}
