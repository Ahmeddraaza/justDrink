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

class _PaywallView extends StatelessWidget {
  const _PaywallView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JustDrink PRO'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<PurchaseCubit, PurchaseState>(
        listener: (context, state) {
          if (state.purchaseSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Welcome to PRO! 💎')),
            );
            context.pop();
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const _PremiumFeature(
                      icon: Icons.block,
                      title: 'No Ads',
                      subtitle: 'Clean, distraction-free experience.',
                    ),
                    const _PremiumFeature(
                      icon: Icons.notifications_active_outlined,
                      title: 'Unlimited Reminders',
                      subtitle: 'Set as many daily alerts as you need.',
                    ),
                    const _PremiumFeature(
                      icon: Icons.edit_note_rounded,
                      title: 'Custom Notif Text',
                      subtitle: 'Personalize your hydration nudges.',
                    ),
                    const _PremiumFeature(
                      icon: Icons.settings_input_component,
                      title: 'Custom Log Volumes',
                      subtitle: 'Tailor quick-add buttons to your favorite cups.',
                    ),
                    const SizedBox(height: 40),
                    if (state.products.isEmpty)
                      Center(
                        child: Text(
                          'Store unavailable. Please check your internet.',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ...state.products.map((product) => _ProductCard(
                          title: product.title.split('(').first,
                          price: product.price,
                          onTap: state.isPurchasing
                              ? null
                              : () => context.read<PurchaseCubit>().buyProduct(product),
                        )),
                  ],
                ),
              ),
              TextButton(
                onPressed: state.isPurchasing
                    ? null
                    : () => context.read<PurchaseCubit>().restore(),
                child: const Text('Restore Purchases'),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _PremiumFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PremiumFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final VoidCallback? onTap;

  const _ProductCard({
    required this.title,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.primary, width: 1),
      ),
      child: ListTile(
        title: Text(title, style: AppTextStyles.bodyLarge),
        trailing: Text(
          price,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
