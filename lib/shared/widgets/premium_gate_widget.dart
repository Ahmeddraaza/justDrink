import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../shared/cubits/ad/ad_cubit.dart';
import '../../../shared/cubits/ad/ad_state.dart';

class PremiumGateWidget extends StatelessWidget {
  final Widget child;

  const PremiumGateWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdCubit, AdState>(
      builder: (context, state) {
        return Stack(
          children: [
            Opacity(
              opacity: state.isPremium ? 1.0 : 0.5,
              child: IgnorePointer(
                ignoring: !state.isPremium,
                child: child,
              ),
            ),
            if (!state.isPremium)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push(Routes.paywall),
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(
                        Icons.lock_outline,
                        color: Colors.amber,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
