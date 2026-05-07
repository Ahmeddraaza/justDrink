import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/progress_ring_widget.dart';
import '../widgets/quick_add_button.dart';
import '../widgets/undo_button.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/database/daos/water_log_dao.dart';
import '../../../data/database/daos/user_profile_dao.dart';
import '../../../data/preferences/preferences_service.dart';
import '../../../shared/cubits/ad/ad_cubit.dart';
import '../../../shared/cubits/widget_sync/widget_sync_cubit.dart';
import '../../../shared/widgets/banner_ad_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DashboardCubit(
            waterLogDao: GetIt.I<WaterLogDao>(),
            userProfileDao: GetIt.I<UserProfileDao>(),
            preferencesService: GetIt.I<PreferencesService>(),
            adCubit: context.read<AdCubit>(),
            widgetSyncCubit: context.read<WidgetSyncCubit>(),
          )..initialize(),
        ),
      ],
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JustDrink', style: AppTextStyles.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                return ProgressRingWidget(
                  current: state.currentIntakeMl,
                  goal: state.dailyGoalMl,
                );
              },
            ),
            const Spacer(),
            BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                return UndoButton(
                  visible: state.showUndo,
                  onTap: () => context.read<DashboardCubit>().undoLastLog(),
                );
              },
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      QuickAddButton(
                        label: '+${state.quickAdd1Ml}ml',
                        onTap: () => context
                            .read<DashboardCubit>()
                            .logWater(state.quickAdd1Ml),
                      ),
                      const SizedBox(width: 16),
                      QuickAddButton(
                        label: '+${state.quickAdd2Ml}ml',
                        onTap: () => context
                            .read<DashboardCubit>()
                            .logWater(state.quickAdd2Ml),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _showCustomLogSheet(context),
              child: Text(
                'Log other amount',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
              ),
            ),
            const Spacer(),
            // Ad Placeholder
            const BannerAdWidget(),
            // Bottom Nav (Manual Implementation)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavButton(
                    icon: Icons.dashboard_rounded,
                    label: 'Home',
                    active: true,
                    onTap: () {},
                  ),
                  _NavButton(
                    icon: Icons.history_rounded,
                    label: 'History',
                    active: false,
                    onTap: () => context.go(Routes.history),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomLogSheet(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Custom Amount', style: AppTextStyles.h2),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                suffixText: 'ml',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final amount = int.tryParse(controller.text);
                if (amount != null && amount > 0) {
                  context.read<DashboardCubit>().logWater(amount);
                  Navigator.pop(sheetContext);
                }
              },
              child: const Text('Log Water'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: active ? AppColors.primary : Colors.white30,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: active ? AppColors.primary : Colors.white30,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
