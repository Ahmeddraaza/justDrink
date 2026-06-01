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
import '../../../core/constants/route_constants.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/analytics_service.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfileData?>(
      stream: GetIt.I<UserProfileDao>().watchProfile(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final isPremium = profile?.isPremium ?? false;
        final activeProductId = profile?.premiumProductId;

        return BlocProvider(
          create: (context) => PurchaseCubit(
            purchaseService: GetIt.I<PurchaseService>(),
            adCubit: context.read<AdCubit>(),
            userProfileDao: GetIt.I<UserProfileDao>(),
          )..initialize(),
          child: _PaywallView(
            isPremium: isPremium,
            activeProductId: activeProductId,
          ),
        );
      },
    );
  }
}

class _PaywallView extends StatefulWidget {
  final bool isPremium;
  final String? activeProductId;

  const _PaywallView({
    required this.isPremium,
    this.activeProductId,
  });

  @override
  State<_PaywallView> createState() => _PaywallViewState();
}

class _PaywallViewState extends State<_PaywallView> {
  String _selectedPlanId = 'justdrink_pro_annual'; // Default selected plan

  @override
  void initState() {
    super.initState();
    try {
      AnalyticsService.logViewSubscription();
    } catch (e) {
      debugPrint('Analytics failed: $e');
    }
  }

  // Vibrant branding colors requested: 5DCCFC (Sky Blue), 0C8AE4 (Deep Sky Blue) & White
  static const Color planLight = Color(0xFF5DCCFC);
  static const Color planAccent = Color(0xFF0C8AE4);

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
          onPressed: () {
            // Check premium state synchronously via AdCubit to avoid async context gap
            final adCubit = context.read<AdCubit>();
            if (!adCubit.state.isPremium) {
              adCubit.showInterstitial();
            }

            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Routes.dashboard);
            }
          },
        ),
      ),
      body: BlocConsumer<PurchaseCubit, PurchaseState>(
        // Only fire listener when a message actually changes — prevents stale replays
        listenWhen: (prev, curr) =>
            prev.purchaseSuccess != curr.purchaseSuccess ||
            prev.feedbackMessage != curr.feedbackMessage ||
            prev.errorMessage != curr.errorMessage,
        listener: (context, state) {
          if (state.purchaseSuccess) {
            try {
              AnalyticsService.logPurchaseSuccess(planId: _selectedPlanId);
            } catch (e) {
              debugPrint('Analytics failed: $e');
            }
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Routes.dashboard);
            }
          }
          if (!state.purchaseSuccess && state.feedbackMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.feedbackMessage!),
                backgroundColor: planAccent,
              ),
            );
            // Consume the message so it can never replay on next state change
            context.read<PurchaseCubit>().clearMessages();
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
            // Consume the error so it can never replay on next state change
            context.read<PurchaseCubit>().clearMessages();
          }
        },
        builder: (context, state) {
          if (widget.isPremium) {
            return _buildActivePlanView(context);
          }

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

          // Fix #7: Don't hardcode USD prices — show unavailable if products not loaded
          final List<_PlanOption> plans = [
            _PlanOption(
              id: 'justdrink_pro_weekly',
              title: 'Weekly',
              description: 'Auto-renews weekly',
              badgeText: 'Try it',
              priceText: weeklyProduct?.price ?? '—',
              rawProduct: weeklyProduct,
            ),
            _PlanOption(
              id: 'justdrink_pro_annual',
              title: 'Yearly',
              description: 'Auto-renews yearly',
              badgeText: 'Save 60%',
              priceText: annualProduct?.price ?? '—',
              rawProduct: annualProduct,
            ),
            _PlanOption(
              id: 'justdrink_pro_lifetime',
              title: 'Lifetime',
              description: 'One-time, forever',
              badgeText: 'Best Value',
              priceText: lifetimeProduct?.price ?? '—',
              rawProduct: lifetimeProduct,
            ),
          ];

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Image.asset(
                      'assets/images/subs_screen_img.png',
                      height: 85,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unlock Your Ultimate Hydration',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        color: AppColors.heading,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Stay perfectly hydrated and healthy daily.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.body,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 3.2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: const [
                        _FeatureTile(title: 'Remove Ads', icon: Icons.block_rounded),
                        _FeatureTile(title: 'Custom Reminders', icon: Icons.notifications_active_rounded),
                        _FeatureTile(title: 'Home Widget', icon: Icons.widgets_rounded),
                        _FeatureTile(title: 'Custom Drink Sizes', icon: Icons.water_drop_rounded),
                      ],
                    ),
                    ...plans.map((plan) {
                      final isSelected = _selectedPlanId == plan.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedPlanId = plan.id),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? planAccent : const Color(0xFFE2E8F0),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: planAccent.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))]
                                : null,
                          ),
                          child: Row(
                            children: [
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
                                        decoration: const BoxDecoration(color: planAccent, shape: BoxShape.circle),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      plan.title,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.heading,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      plan.description,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
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
                                      color: planAccent.withOpacity(0.10),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      plan.badgeText,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: planAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    plan.priceText,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      color: AppColors.heading,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ]),
                ),
              ),

              // SliverFillRemaining: button section pins to bottom, zero artificial whitespace
              SliverFillRemaining(
                hasScrollBody: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [planLight, planAccent],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: planAccent.withOpacity(0.24),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            onPressed: state.isPurchasing
                                ? null
                                : () {
                                    final selectedPlan = plans.firstWhere((p) => p.id == _selectedPlanId);
                                    if (selectedPlan.rawProduct != null) {
                                      try {
                                        AnalyticsService.logClickSubscribe(planId: _selectedPlanId);
                                      } catch (e) {
                                        debugPrint('Analytics failed: $e');
                                      }
                                      context.read<PurchaseCubit>().buyProduct(selectedPlan.rawProduct!);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Store is temporarily unavailable. Please try again.'),
                                          backgroundColor: Color(0xFF0C8AE4),
                                        ),
                                      );
                                    }
                                  },
                            child: state.isPurchasing
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                  )
                                : Text(
                                    'Subscribe Now',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                        TextButton(
                          onPressed: state.isPurchasing
                              ? null
                              : () => context.read<PurchaseCubit>().restore(),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.body,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                          ),
                          child: Text(
                            'Restore Purchases',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "By subscribing, you agree to our",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: AppColors.body.withOpacity(0.6),
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => _launchURL('https://hanotech.net/terms'),
                              child: Text(
                                'Terms of Service',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.body,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '&',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.body.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _launchURL('https://hanotech.net/privacy-policy'),
                              child: Text(
                                'Privacy Policy',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.body,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );

        },
      ),
    );
  }

  Widget _buildActivePlanView(BuildContext context) {
    String planName = 'Premium Pro Active';
    String billingInfo = 'Thank you for supporting JustDrink!';
    
    if (widget.activeProductId == 'justdrink_pro_weekly') {
      planName = 'Weekly Pro Pass';
      billingInfo = 'Auto-renews weekly. Manage anytime in App Store settings.';
    } else if (widget.activeProductId == 'justdrink_pro_annual') {
      planName = 'Annual Pro Pass';
      billingInfo = 'Auto-renews annually. Manage anytime in App Store settings.';
    } else if (widget.activeProductId == 'justdrink_pro_lifetime') {
      planName = 'Lifetime Unlimited';
      billingInfo = 'One-time purchase. Enjoy lifetime premium access!';
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gorgeous premium golden & blue crown badge
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5DCCFC), Color(0xFF0C8AE4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0C8AE4).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 56,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "You're a PRO Member!",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.heading,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0C8AE4).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF0C8AE4).withOpacity(0.2),
                ),
              ),
              child: Text(
                planName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0C8AE4),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                billingInfo,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.body.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Features Unlocked Checklist
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'YOUR PREMIUM BENEFITS:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.body.withOpacity(0.6),
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildBenefitRow(
              icon: Icons.block_rounded,
              title: 'Ad-Free Experience',
              description: 'Zero distraction, complete screen real estate.',
            ),
            const SizedBox(height: 12),
            _buildBenefitRow(
              icon: Icons.water_drop_rounded,
              title: 'Custom Drink Sizes',
              description: 'Customize quick-add buttons to fit your custom bottles.',
            ),
            const SizedBox(height: 12),
            _buildBenefitRow(
              icon: Icons.notifications_active_rounded,
              title: '10 Smart Spaced Reminders',
              description: 'Stay hydrated with fully spacing notifications.',
            ),
            const SizedBox(height: 12),
            _buildBenefitRow(
              icon: Icons.widgets_rounded,
              title: 'Home Screen Widgets',
              description: 'Access beautiful widget designs directly on your home.',
            ),
            const SizedBox(height: 40),

            // Action CTAs
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C8AE4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () => _launchURL('https://apps.apple.com/account/subscriptions'),
                child: Text(
                  'Manage Subscription',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(Routes.dashboard);
                }
              },
              child: Text(
                'Back to Dashboard',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.body,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF0C8AE4).withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: const Color(0xFF0C8AE4),
            size: 18,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.heading,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.body.withOpacity(0.8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String title;
  final IconData icon;

  const _FeatureTile({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0C8AE4).withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF0C8AE4).withOpacity(0.14),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5DCCFC), Color(0xFF0C8AE4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 15),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A2B4A),
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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
