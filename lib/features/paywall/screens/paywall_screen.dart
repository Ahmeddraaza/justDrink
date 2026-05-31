import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../cubit/purchase_cubit.dart';
import '../cubit/purchase_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/purchase_service.dart';
import '../../../shared/cubits/ad/ad_cubit.dart';
import '../../../data/database/daos/user_profile_dao.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PurchaseCubit(
        purchaseService: GetIt.I<PurchaseService>(),
        adCubit: context.read<AdCubit>(),
        userProfileDao: GetIt.I<UserProfileDao>(),
      )..initialize(),
      child: const _PaywallView(),
    );
  }
}

class _PaywallView extends StatefulWidget {
  const _PaywallView();

  @override
  State<_PaywallView> createState() => _PaywallViewState();
}

class _PaywallViewState extends State<_PaywallView> {
  String _selectedPlanId = 'justdrink_pro_annual'; // Default selected plan

  // Highly cohesive ocean blue matching the app's primary and wave colors
  static const Color planAccent = AppColors.wave2;
  static const Color planPrimaryLight = AppColors.primary;

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.heading),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<PurchaseCubit, PurchaseState>(
        listener: (context, state) {
          if (state.purchaseSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Welcome to PRO! 💎'),
                backgroundColor: planAccent,
              ),
            );
            context.pop();
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(planAccent),
              ),
            );
          }

          // Distribute real products if available
          ProductDetails? weeklyProduct;
          ProductDetails? annualProduct;
          ProductDetails? lifetimeProduct;

          for (final p in state.products) {
            if (p.id == 'justdrink_pro_weekly') weeklyProduct = p;
            if (p.id == 'justdrink_pro_annual') annualProduct = p;
            if (p.id == 'justdrink_pro_lifetime') lifetimeProduct = p;
          }

          final List<_PlanOption> plans = [
            _PlanOption(
              id: 'justdrink_pro_weekly',
              title: 'Weekly Plan',
              description: 'Best to try out features',
              badgeText: 'Save 0%',
              priceText: weeklyProduct?.price ?? '\$0.99',
              rawProduct: weeklyProduct,
            ),
            _PlanOption(
              id: 'justdrink_pro_annual',
              title: 'Yearly Plan',
              description: 'Most Popular',
              badgeText: 'Save 60%',
              priceText: annualProduct?.price ?? '\$19.99',
              rawProduct: annualProduct,
            ),
            _PlanOption(
              id: 'justdrink_pro_lifetime',
              title: 'Lifetime Access',
              description: 'One-time payment forever',
              badgeText: 'Best Value',
              priceText: lifetimeProduct?.price ?? '\$29.99',
              rawProduct: lifetimeProduct,
            ),
          ];

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header Section - short, catchy one-liner
                      Text(
                        'Unlock Your Ultimate Hydration',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 22,
                          color: AppColors.heading,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Stay perfectly hydrated and healthy daily.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.body,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Premium Grid list (2 Columns)
                      const Row(
                        children: [
                          Expanded(
                            child: _PremiumGridItem(
                              title: 'Remove Ads',
                            ),
                          ),
                          Expanded(
                            child: _PremiumGridItem(
                              title: 'Custom Reminders',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Expanded(
                            child: _PremiumGridItem(
                              title: 'Home Screen Widget',
                            ),
                          ),
                          Expanded(
                            child: _PremiumGridItem(
                              title: 'Custom Log Volumes',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Plan list cards
                      ...plans.map((plan) {
                        final isSelected = _selectedPlanId == plan.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPlanId = plan.id;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? planAccent : const Color(0xFFE2E8F0),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: planAccent.withOpacity(0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                // Custom Radio design matching screenshot
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? planAccent : const Color(0xFF94A3B8),
                                      width: 2,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: isSelected
                                      ? Container(
                                          width: 12,
                                          height: 12,
                                          decoration: const BoxDecoration(
                                            color: planAccent,
                                            shape: BoxShape.circle,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        plan.title,
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.heading,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        plan.description,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: isSelected ? planAccent : AppColors.body,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: planAccent.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        plan.badgeText,
                                        style: const TextStyle(
                                          color: planAccent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      plan.priceText,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.heading,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Bottom Button, Restore & Hyperlinks Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: planAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: state.isPurchasing
                            ? null
                            : () {
                                final selectedPlan = plans.firstWhere((p) => p.id == _selectedPlanId);
                                if (selectedPlan.rawProduct != null) {
                                  context.read<PurchaseCubit>().buyProduct(selectedPlan.rawProduct!);
                                } else {
                                  // Fallback simulation for offline/simulators
                                  context.read<PurchaseCubit>().buyProduct(
                                        ProductDetails(
                                          id: selectedPlan.id,
                                          title: selectedPlan.title,
                                          description: selectedPlan.description,
                                          price: selectedPlan.priceText,
                                          rawPrice: 0.0,
                                          currencyCode: 'USD',
                                        ),
                                      );
                                }
                              },
                        child: state.isPurchasing
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Subscribe Now',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: state.isPurchasing
                          ? null
                          : () => context.read<PurchaseCubit>().restore(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.body,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                      child: const Text('Restore Purchases'),
                    ),
                    const SizedBox(height: 4),
                    
                    // Hyperlinks for Terms and Privacy Policy
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => _launchURL('https://hanotech.net/terms'),
                          child: Text(
                            'Terms of Service',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.body,
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.body,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _launchURL('https://hanotech.net/privacy-policy'),
                          child: Text(
                            'Privacy Policy',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.body,
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PremiumGridItem extends StatelessWidget {
  final String title;

  const _PremiumGridItem({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_outline_rounded,
          color: _PaywallViewState.planAccent,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.heading,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _PlanOption {
  final String id;
  final String title;
  final String description;
  final String badgeText;
  final String priceText;
  final ProductDetails? rawProduct;

  _PlanOption({
    required this.id,
    required this.title,
    required this.description,
    required this.badgeText,
    required this.priceText,
    this.rawProduct,
  });
}
