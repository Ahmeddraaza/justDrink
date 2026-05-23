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
import '../../../shared/cubits/widget_sync/widget_sync_cubit.dart';
import '../../../shared/widgets/floating_navbar.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryCubit(
        waterLogDao: GetIt.I<WaterLogDao>(),
        widgetSyncCubit: context.read<WidgetSyncCubit>(),
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
        title: Text('Insights', style: AppTextStyles.h2.copyWith(color: AppColors.heading)),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.heading),
          onPressed: () => context.push(Routes.settings),
        ),
        actions: const [
          SizedBox(width: 48),
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

          // Only display the 3 most recent logs under activity log
          final displayedLogs = state.selectedDayLogs.take(3).toList();

          return RefreshIndicator(
            onRefresh: () async => context.read<HistoryCubit>().refreshTotals(),
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
                    if (state.selectedDayLogs.length > 3)
                      TextButton(
                        onPressed: () => _showAllLogsBottomSheet(context, state),
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
                else ...[
                  ...displayedLogs.map((log) => LogEntryTile(
                        log: log,
                        onDelete: () => context.read<HistoryCubit>().deleteLog(log.id),
                      )),
                  if (state.selectedDayLogs.length > 3)
                    Center(
                      child: TextButton(
                        onPressed: () => _showAllLogsBottomSheet(context, state),
                        child: Text(
                          'And ${state.selectedDayLogs.length - 3} more logs',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAllLogsBottomSheet(BuildContext context, HistoryState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return BlocProvider.value(
          value: context.read<HistoryCubit>(),
          child: BlocBuilder<HistoryCubit, HistoryState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Logs (${state.selectedDayLogs.length})',
                          style: AppTextStyles.h3.copyWith(color: AppColors.heading),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (state.selectedDayLogs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: Text('No logs recorded')),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.selectedDayLogs.length,
                          itemBuilder: (context, index) {
                            final log = state.selectedDayLogs[index];
                            return LogEntryTile(
                              log: log,
                              onDelete: () {
                                context.read<HistoryCubit>().deleteLog(log.id);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
