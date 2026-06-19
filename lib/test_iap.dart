import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

void test() async {
  final addition = InAppPurchase.instance.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
  final response = await addition.queryPastPurchases();
  for (var p in response.pastPurchases) {
    print(p.productID);
  }
}
