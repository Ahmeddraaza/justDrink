import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../cubit/history_cubit.dart';
import '../cubit/history_state.dart';
import '../widgets/weekly_bar_chart.dart';
import '../widgets/log_entry_tile.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/database/daos/water_log_dao.dart';
import '../../../data/database/daos/user_profile_dao.dart';
import '../../../shared/widgets/banner_ad_widget.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryCubit(
        waterLogDao: GetIt.I<WaterLogDao>(),
      )..initialize(),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History', style: AppTextStyles.h2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.dashboard),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text('Last 7 Days', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 16),
                  BlocBuilder<HistoryCubit, HistoryState>(
                    builder: (context, state) {
                      return WeeklyBarChart(
                        totals: state.weeklyTotals,
                        goalMl: 2500, // Ideally from a shared state or profile
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Today\'s Logs', style: AppTextStyles.bodyMedium),
                      const Icon(Icons.calendar_today, size: 16, color: Colors.white30),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<HistoryCubit, HistoryState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state.selectedDayLogs.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Text(
                              'No logs for today',
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: state.selectedDayLogs
                            .map((log) => LogEntryTile(
                                  log: log,
                                  onDelete: () => context
                                      .read<HistoryCubit>()
                                      .deleteLog(log.id),
                                ))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const BannerAdWidget(),
            // Bottom Nav
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
                    active: false,
                    onTap: () => context.go(Routes.dashboard),
                  ),
                  _NavButton(
                    icon: Icons.history_rounded,
                    label: 'History',
                    active: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
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
