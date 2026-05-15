import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:drift/drift.dart';
import '../core/constants/notification_constants.dart';
import '../core/utils/notification_scheduler.dart';
import '../data/database/app_database.dart';
import '../data/database/daos/user_profile_dao.dart';
import 'package:home_widget/home_widget.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ── Initialization ──────────────────────────────────────────────────
  Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS: Register action categories here
    final iosInit = DarwinInitializationSettings(
      notificationCategories: [
        DarwinNotificationCategory(
          NotificationConstants.hydrationCategoryId,
          actions: [
            DarwinNotificationAction.plain(
              NotificationConstants.actionLog250,
              'Log 250ml',
              options: {DarwinNotificationActionOption.foreground},
            ),
            DarwinNotificationAction.plain(
              NotificationConstants.actionSnooze10,
              'Snooze 10m',
              options: {DarwinNotificationActionOption.foreground},
            ),
          ],

        ),
      ],
    );

    try {
      await _plugin.initialize(
        InitializationSettings(android: androidInit, iOS: iosInit),
        onDidReceiveNotificationResponse: _onNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationResponse,
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Notification plugin initialization failed or timed out: $e');
    }
  }

  // ── Permission ───────────────────────────────────────────────────────
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission() ?? false;

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);

    return granted;
  }

  Future<bool> checkPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final status = await android?.areNotificationsEnabled() ?? false;
    return status;
  }

  Future<void> scheduleAll({
    required String wakeTime,
    required String sleepTime,
    required int reminderCount,
    required String notificationText,
    required bool isPremium,
  }) async {
    await cancelAll();

    final times = NotificationScheduler.generate(
      wakeTime: wakeTime,
      sleepTime: sleepTime,
      count: reminderCount,
    );

    for (int i = 0; i < times.length; i++) {
      final time = times[i];
      await _plugin.zonedSchedule(
        i,
        'JustDrink 💧',
        notificationText,
        time,
        NotificationDetails(
          android: AndroidNotificationDetails(
            NotificationConstants.channelId,
            NotificationConstants.channelName,
            channelDescription: NotificationConstants.channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            actions: [
              AndroidNotificationAction(
                NotificationConstants.actionLog250,
                'Log 250ml',
                cancelNotification: true,
              ),
              AndroidNotificationAction(
                NotificationConstants.actionSnooze10,
                'Snooze 10m',
                cancelNotification: true,
              ),
            ],
          ),
          iOS: DarwinNotificationDetails(
            categoryIdentifier: NotificationConstants.hydrationCategoryId,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> rescheduleAll(UserProfileData profile) async {
    final text = profile.customNotificationText ?? 'Time to drink water!';
    final count = profile.isPremium
        ? profile.reminderCount
        : profile.reminderCount.clamp(1, 6);
    await scheduleAll(
      wakeTime: profile.wakeTime,
      sleepTime: profile.sleepTime,
      reminderCount: count,
      notificationText: text,
      isPremium: profile.isPremium,
    );
  }

  // ── Action Handling ──────────────────────────────────────────────────
  static void _onNotificationResponse(NotificationResponse response) {
    _handleAction(response.actionId, response.id);
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) {
    _handleAction(response.actionId, response.id);
  }

  static Future<void> _handleAction(String? actionId, int? notifId) async {
    if (actionId == NotificationConstants.actionLog250) {
      final db = AppDatabase();
      await db.waterLogDao.logWater(amountMl: 250, source: 'widget');
      await _updateWidgetAfterBackgroundLog(db);
      await db.close();
    } else if (actionId == NotificationConstants.actionSnooze10) {
      final plugin = FlutterLocalNotificationsPlugin();
      if (notifId != null) {
        await plugin.cancel(notifId);
        final snoozeTime = tz.TZDateTime.now(tz.local).add(
          const Duration(minutes: 10),
        );
        await plugin.zonedSchedule(
          notifId + 1000,
          'JustDrink 💧',
          'Time to drink water! (Snoozed)',
          snoozeTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              NotificationConstants.channelId,
              NotificationConstants.channelName,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  static Future<void> _updateWidgetAfterBackgroundLog(AppDatabase db) async {
    final total = await db.waterLogDao.getTodayTotalMl();
    final profile = await db.userProfileDao.getProfile();
    if (profile != null) {
      await HomeWidget.saveWidgetData('currentMl', total);
      await HomeWidget.saveWidgetData('goalMl', profile.dailyGoalMl);
      await HomeWidget.updateWidget(
        androidName: 'JustDrinkWidgetProvider',
        iOSName: 'JustDrinkWidget',
      );
    }
  }
}
