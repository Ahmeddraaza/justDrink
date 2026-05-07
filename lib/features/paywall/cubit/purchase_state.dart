import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseState extends Equatable {
  final List<ProductDetails> products;
  final bool isLoading;
  final bool isPurchasing;
  final String? errorMessage;
  final bool purchaseSuccess;

  const PurchaseState({
    this.products = const [],
    this.isLoading = false,
    this.isPurchasing = false,
    this.errorMessage,
    this.purchaseSuccess = false,
  });

  PurchaseState copyWith({
    List<ProductDetails>? products,
    bool? isLoading,
    bool? isPurchasing,
    String? errorMessage,
    bool? purchaseSuccess,
  }) {
    return PurchaseState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      errorMessage: errorMessage ?? this.errorMessage,
      purchaseSuccess: purchaseSuccess ?? this.purchaseSuccess,
    );
  }

  @override
  List<Object?> get props => [products, isLoading, isPurchasing, errorMessage, purchaseSuccess];
}
