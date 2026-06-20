import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/ad/ad_cubit.dart';
import '../cubits/ad/ad_state.dart';

/// On the free-adfree-premium branch, isPremium is always true in the DAO.
/// This widget still exists to avoid breaking any existing usages,
/// but simply renders [child] at full opacity since all features are unlocked.
class PremiumGateWidget extends StatelessWidget {
  final Widget child;

  const PremiumGateWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdCubit, AdState>(
      builder: (context, state) {
        // All features are unlocked on this branch — always render child normally
        return child;
      },
    );
  }
}
