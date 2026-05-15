import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SettingsHeader extends StatelessWidget {
  final int dailyGoal;
  final double weight;
  final bool isPremium;

  const SettingsHeader({
    super.key,
    required this.dailyGoal,
    required this.weight,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.dashboardBackground,
            Color(0xFF1A3A70),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.dashboardBackground.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              isPremium ? Icons.workspace_premium_outlined : Icons.person_outline,
              size: 100,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Your Profile',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isPremium) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.withOpacity(0.5)),
                      ),
                      child: Text(
                        'PRO',
                        style: TextStyle(
                          color: Colors.amber[200],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoColumn(
                    label: 'Goal',
                    value: '${dailyGoal}ml',
                  ),
                  const SizedBox(width: 32),
                  _InfoColumn(
                    label: 'Weight',
                    value: '${weight}kg',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (!isPremium)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Unlock all features with JustDrink PRO',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white60, size: 20),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;

  const _InfoColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white60, fontSize: 12),
        ),
        Text(
          value,
          style: AppTextStyles.h2.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
