import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../cubit/history_cubit.dart';
import '../cubit/history_state.dart';
import '../widgets/history_header.dart';
import '../widgets/history_chart_section.dart';
import '../widgets/log_entry_tile.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/database/daos/water_log_dao.dart';
import '../../../shared/widgets/banner_ad_widget.dart';
import '../../../shared/widgets/floating_navbar.dart';

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
      backgroundColor: Colors.white,
      extendBody: true,
      appBar: AppBar(
        title: Text('Statistics', style: AppTextStyles.h2.copyWith(color: AppColors.heading)),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.heading),
          onPressed: () => context.push(Routes.settings),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined, color: AppColors.heading),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdWidget(),
          const FloatingNavbar(activeRoute: Routes.history),
        ],
      ),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state.isLoading && state.weeklyTotals.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final todayTotalMl = state.weeklyTotals.isNotEmpty 
              ? state.weeklyTotals.last.totalMl 
              : 0;

          return RefreshIndicator(
            onRefresh: () => context.read<HistoryCubit>().refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              children: [
                HistoryHeader(
                  todayTotalMl: todayTotalMl,
                  goalMl: 2500, // This should probably come from a user settings cubit
                ),
                const SizedBox(height: 32),
                HistoryChartSection(
                  totals: state.weeklyTotals,
                  period: state.period,
                  goalMl: 2500,
                  onPeriodChanged: (period) => 
                      context.read<HistoryCubit>().changePeriod(period),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Activity Logs',
                      style: AppTextStyles.h3.copyWith(color: AppColors.heading),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'View All',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (state.selectedDayLogs.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(Icons.history_toggle_off, size: 48, color: AppColors.body.withOpacity(0.3)),
                          const SizedBox(height: 12),
                          Text(
                            'No activity for today yet',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.body),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...state.selectedDayLogs.map((log) => LogEntryTile(
                        log: log,
                        onDelete: () => context.read<HistoryCubit>().deleteLog(log.id),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}
