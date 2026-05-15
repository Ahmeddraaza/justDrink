import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  late SharedPreferences _prefs;

  static final PreferencesService instance = PreferencesService._();
  PreferencesService._();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool? getBool(String key) => _prefs.getBool(key);
  int? getInt(String key) => _prefs.getInt(key);
  String? getString(String key) => _prefs.getString(key);
  double? getDouble(String key) => _prefs.getDouble(key);

  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);
  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);
  Future<void> setString(String key, String value) => _prefs.setString(key, value);
  Future<void> setDouble(String key, double value) => _prefs.setDouble(key, value);

  Future<void> remove(String key) => _prefs.remove(key);
  Future<void> clear() => _prefs.clear();

  // ── Ad Counter with daily reset ──────────────────────────────────
  static const _adCounterKey     = 'ad_log_counter';
  static const _adCounterDateKey = 'ad_log_counter_date';

  Future<int> getAndIncrementAdCounter() async {
    final storedDate = getString(_adCounterDateKey);
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (storedDate != today) {
      // New day — reset counter
      await setString(_adCounterDateKey, today);
      await setInt(_adCounterKey, 1);
      return 1;
    }

    final current = getInt(_adCounterKey) ?? 0;
    final next = current + 1;
    await setInt(_adCounterKey, next);
    return next;
  }

  // ── Convenience keys ──────────────────────────────────────────────
  bool get isOnboardingComplete => getBool('onboarding_complete') ?? false;
  bool get isPremium => getBool('is_premium') ?? false;
  String? get premiumProductId => getString('premium_product_id');
  bool get notificationPermissionAsked => getBool('notification_permission_asked') ?? false;
  
  bool get isWidgetAdded => getBool('is_widget_added') ?? false;
  Future<void> setIsWidgetAdded(bool value) => setBool('is_widget_added', value);
}
