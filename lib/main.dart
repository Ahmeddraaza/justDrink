import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get_it/get_it.dart';

import 'core/di/injection.dart';
import 'data/preferences/preferences_service.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/widget_service.dart';
import 'services/purchase_service.dart';
import 'services/ad_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Timezone (must be before notifications)
  tz.initializeTimeZones();
  final localTimezone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(localTimezone));

  // 2. SharedPreferences
  await PreferencesService.instance.initialize();

  // 3. Drift Database
  await DatabaseService.initialize();

  // 4. Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // 5. Widget Service
  final widgetService = WidgetService();
  await widgetService.initialize();

  // 6. Ad Service (init MobileAds SDK)
  final adService = AdService();
  await adService.initialize();

  // 7. Purchase Service (init stream listener)
  final purchaseService = PurchaseService();
  await purchaseService.initialize();

  // 8. Register all with GetIt
  final sl = GetIt.instance;
  DatabaseService.registerWithGetIt(sl);
  sl.registerSingleton<NotificationService>(notificationService);
  sl.registerSingleton<WidgetService>(widgetService);
  sl.registerSingleton<AdService>(adService);
  sl.registerSingleton<PurchaseService>(purchaseService);
  sl.registerSingleton<PreferencesService>(PreferencesService.instance);

  runApp(const JustDrinkApp());
}
