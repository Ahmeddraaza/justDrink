import 'dart:io';

class AppConstants {
  // AdMob App IDs (Configure these in your App Store / Play Store builds)
  // iOS: ca-app-pub-5090695120550921~8635440008
  // Android: ca-app-pub-3940256099942544~3347511713 (TEST ID - PLEASE REPLACE)

  static String get interstitialAdUnitId {
    if (Platform.isIOS) {
      return 'ca-app-pub-5090695120550921/1737339255';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-5090695120550921/6405896321';
    }
    return '';
  }

  // Widget identifiers
  static const widgetAppGroupId = 'group.com.hanotech.justdrinkfreemium.appgroup';
  static const widgetAndroidName = 'JustDrinkWidgetProvider';
  static const widgetIOSName = 'JustDrinkWidget';

  // Purchase Product IDs
  static const productMonthly = 'justdrink_pro_monthly';
  static const productAnnual = 'justdrink_pro_annual';
}
