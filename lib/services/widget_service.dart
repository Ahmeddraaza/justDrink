import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import '../data/database/app_database.dart';

class WidgetService {
  static const _appGroupId   = 'group.com.swifteck.justdrink';  // iOS App Group
  static const _androidClass = 'com.justdrink.app.JustDrinkWidgetProvider';
  static const _iOSName      = 'JustDrinkWidget';

  Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_appGroupId);
    // Register callback for when widget button is tapped
    HomeWidget.registerInteractivityCallback(_widgetBackgroundCallback);
  }

  // Called by any cubit after data changes
  Future<void> updateWidget({
    required int currentMl,
    required int goalMl,
    required bool isPremium,
    String theme = 'default',
  }) async {
    final glassSize = (goalMl / 10).round(); // Default to 1/10th of goal
    
    await HomeWidget.saveWidgetData<int>('currentMl', currentMl);
    await HomeWidget.saveWidgetData<int>('goalMl', goalMl);
    await HomeWidget.saveWidgetData<int>('glassSize', glassSize);
    await HomeWidget.saveWidgetData<int>('glassesCount', (currentMl / glassSize).floor());
    await HomeWidget.saveWidgetData<String>('theme', isPremium ? theme : 'default');
    await HomeWidget.saveWidgetData<double>(
      'progress',
      goalMl > 0 ? (currentMl / goalMl).clamp(0.0, 1.0) : 0.0,
    );
    await HomeWidget.updateWidget(
      androidName: _androidClass,
      iOSName: _iOSName,
    );
  }

  // Handles widget tap that opens app with amount intent
  Future<void> handleInitialUri() async {
    final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (uri != null) {
      _processWidgetUri(uri);
    }
  }

  // Listen for widget taps while app is in foreground
  Stream<Uri?> get widgetLaunchStream => HomeWidget.widgetClicked;

  static void _processWidgetUri(Uri uri) {
    // URI format: justdrink://log?amount=250
    // Handled by WidgetSyncCubit.handleWidgetTap()
  }

  /// Call this on app resume/foreground to commit any water logged via widget AppIntent
  Future<int?> consumePendingWidgetLog() async {
    final amount = await HomeWidget.getWidgetData<int>('pendingWidgetLogMl');
    if (amount != null && amount > 0) {
      await HomeWidget.saveWidgetData<int>('pendingWidgetLogMl', 0);
    }
    return (amount != null && amount > 0) ? amount : null;
  }

  Future<void> requestPinWidget() async {
    await HomeWidget.requestPinWidget(
      androidName: _androidClass,
    );
  }
}

// Top-level background callback — must be @pragma annotated
@pragma('vm:entry-point')
Future<void> _widgetBackgroundCallback(Uri? uri) async {
  if (uri == null) return;
  final amount = int.tryParse(uri.queryParameters['amount'] ?? '') ?? 0;
  if (amount <= 0) return;

  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  await db.waterLogDao.logWater(amountMl: amount, source: 'widget');

  final total   = await db.waterLogDao.getTodayTotalMl();
  final profile = await db.userProfileDao.getProfile();
  if (profile != null) {
    await HomeWidget.saveWidgetData('currentMl', total);
    await HomeWidget.saveWidgetData('goalMl', profile.dailyGoalMl);
    await HomeWidget.saveWidgetData(
      'progress',
      profile.dailyGoalMl > 0
          ? (total / profile.dailyGoalMl).clamp(0.0, 1.0)
          : 0.0,
    );
    await HomeWidget.updateWidget(
      androidName: 'com.justdrink.app.JustDrinkWidgetProvider',
      iOSName: 'JustDrinkWidget',
    );
  }
  await db.close();
}
