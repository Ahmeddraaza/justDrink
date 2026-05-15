import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../cubit/history_state.dart';
import '../../../data/database/daos/water_log_dao.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HistoryChartSection extends StatelessWidget {
  final List<DailyTotal> totals;
  final HistoryPeriod period;
  final Function(HistoryPeriod) onPeriodChanged;
  final int goalMl;

  const HistoryChartSection({
    super.key,
    required this.totals,
    required this.period,
    required this.onPeriodChanged,
    required this.goalMl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              period == HistoryPeriod.weekly ? 'Weekly Consumption' : 'Monthly Consumption',
              style: AppTextStyles.h3.copyWith(color: AppColors.heading),
            ),
            _PeriodSelector(
              selectedPeriod: period,
              onChanged: onPeriodChanged,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: totals.isEmpty 
            ? const Center(child: Text('No data available'))
            : LineChart(_buildChartData()),
        ),
      ],
    );
  }

  LineChartData _buildChartData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: goalMl / 2,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.black.withOpacity(0.05),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: period == HistoryPeriod.monthly ? 5 : 1,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index < 0 || index >= totals.length) return const SizedBox.shrink();
              
              String text;
              if (period == HistoryPeriod.weekly) {
                text = DateFormat('E').format(totals[index].date).substring(0, 1);
              } else {
                // Show date number for monthly
                text = totals[index].date.day.toString();
              }
              
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  text,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.body.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (totals.length - 1).toDouble(),
      minY: 0,
      maxY: (totals.map((e) => e.totalMl).fold(goalMl, (p, e) => e > p ? e : p)).toDouble() * 1.2,
      lineBarsData: [
        LineChartBarData(
          spots: totals.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value.totalMl.toDouble());
          }).toList(),
          isCurved: true,
          curveSmoothness: 0.35,
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF2B59B3)],
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: AppColors.primary,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.2),
                AppColors.primary.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (spot) => AppColors.heading,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.y.toInt()} ml',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final HistoryPeriod selectedPeriod;
  final Function(HistoryPeriod) onChanged;

  const _PeriodSelector({
    required this.selectedPeriod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildOption(HistoryPeriod.weekly, 'W'),
          _buildOption(HistoryPeriod.monthly, 'M'),
        ],
      ),
    );
  }

  Widget _buildOption(HistoryPeriod period, String label) {
    final isSelected = selectedPeriod == period;
    return GestureDetector(
      onTap: () => onChanged(period),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? AppColors.heading : AppColors.body,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
