import Flutter
import UIKit
import StoreKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let envChannel = FlutterMethodChannel(name: "com.hanotech.justdrink/environment",
                                              binaryMessenger: controller.binaryMessenger)
    envChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "isSandbox" {
        let isSandbox = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        result(isSandbox)
      } else if call.method == "hasActiveSubscription" {
        guard let productIds = call.arguments as? [String] else {
          result(false)
          return
        }
        if #available(iOS 15.0, *) {
          Task {
            let isActive = await self?.checkActiveSubscription(productIds: productIds) ?? false
            DispatchQueue.main.async {
              result(isActive)
            }
          }
        } else {
          // iOS < 15: StoreKit 2 not available, fall back to true (don't expire)
          result(true)
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Uses StoreKit 2 Transaction.currentEntitlements to check for active subscriptions.
  /// This only returns genuinely active (not expired, not revoked) transactions.
  @available(iOS 15.0, *)
  private func checkActiveSubscription(productIds: [String]) async -> Bool {
    for await verificationResult in Transaction.currentEntitlements {
      if case .verified(let transaction) = verificationResult {
        if productIds.contains(transaction.productID) {
          // Check it hasn't been revoked
          if transaction.revocationDate == nil {
            return true
          }
        }
      }
    }
    return false
  }
}

