import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get_it/get_it.dart';
import '../cubits/ad/ad_cubit.dart';
import '../cubits/ad/ad_state.dart';
import '../../../services/ad_service.dart';

class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdCubit, AdState>(
      builder: (context, state) {
        if (state.isPremium || !state.isBannerLoaded) {
          return const SizedBox.shrink();
        }

        final bannerAd = GetIt.I<AdService>().bannerAd;
        if (bannerAd == null) return const SizedBox.shrink();

        return Container(
          alignment: Alignment.center,
          width: bannerAd.size.width.toDouble(),
          height: bannerAd.size.height.toDouble(),
          child: AdWidget(ad: bannerAd),
        );
      },
    );
  }
}
