import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

// Sentinel used to distinguish "not provided" from "explicitly null" in copyWith
// This allows callers to actually clear nullable String fields by passing null.
const _unset = Object();

class PurchaseState extends Equatable {
  final List<ProductDetails> products;
  final bool isLoading;
  final bool isPurchasing;
  final String? errorMessage;
  final String? feedbackMessage;
  final bool purchaseSuccess;

  const PurchaseState({
    this.products = const [],
    this.isLoading = false,
    this.isPurchasing = false,
    this.errorMessage,
    this.feedbackMessage,
    this.purchaseSuccess = false,
  });

  /// Passing [null] for [errorMessage] or [feedbackMessage] CLEARS them.
  /// Omitting them (default _unset) PRESERVES the existing value.
  PurchaseState copyWith({
    List<ProductDetails>? products,
    bool? isLoading,
    bool? isPurchasing,
    Object? errorMessage = _unset,   // use sentinel so null can mean "clear"
    Object? feedbackMessage = _unset,
    bool? purchaseSuccess,
  }) {
    return PurchaseState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      feedbackMessage: feedbackMessage == _unset
          ? this.feedbackMessage
          : feedbackMessage as String?,
      purchaseSuccess: purchaseSuccess ?? this.purchaseSuccess,
    );
  }

  @override
  List<Object?> get props => [
        products,
        isLoading,
        isPurchasing,
        errorMessage,
        feedbackMessage,
        purchaseSuccess,
      ];
}
