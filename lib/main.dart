import 'dart:ui';
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

  try {
    tz.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone().timeout(const Duration(seconds: 2));
    tz.setLocalLocation(tz.getLocation(localTimezone));
  } catch (e) {
    tz.setLocalLocation(tz.getLocation('UTC'));
  }

  await PreferencesService.instance.initialize();

  await DatabaseService.initialize();

  final notificationService = NotificationService();
  try {
    await notificationService.initialize().timeout(const Duration(seconds: 5));
  } catch (e) {}

  final widgetService = WidgetService();
  await widgetService.initialize();

  final adService = AdService();
  try {
    await adService.initialize().timeout(const Duration(seconds: 3));
  } catch (e) {}

  final purchaseService = PurchaseService();
  try {
    await purchaseService.initialize().timeout(const Duration(seconds: 3));
  } catch (e) {}

  final sl = GetIt.instance;
  DatabaseService.registerWithGetIt(sl);
  sl.registerSingleton<NotificationService>(notificationService);
  sl.registerSingleton<WidgetService>(widgetService);
  sl.registerSingleton<AdService>(adService);
  sl.registerSingleton<PurchaseService>(purchaseService);
  sl.registerSingleton<PreferencesService>(PreferencesService.instance);

  runApp(const JustDrinkApp());
}
