import 'package:equatable/equatable.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/daos/water_log_dao.dart';

enum HistoryPeriod { weekly, monthly, yearly }

class HistoryState extends Equatable {
  final List<DailyTotal> weeklyTotals;
  final List<WaterLog> selectedDayLogs;
  final DateTime selectedDate;
  final HistoryPeriod period;
  final bool isLoading;

  const HistoryState({
    this.weeklyTotals = const [],
    this.selectedDayLogs = const [],
    required this.selectedDate,
    this.period = HistoryPeriod.weekly,
    this.isLoading = false,
  });

  HistoryState copyWith({
    List<DailyTotal>? weeklyTotals,
    List<WaterLog>? selectedDayLogs,
    DateTime? selectedDate,
    HistoryPeriod? period,
    bool? isLoading,
  }) {
    return HistoryState(
      weeklyTotals: weeklyTotals ?? this.weeklyTotals,
      selectedDayLogs: selectedDayLogs ?? this.selectedDayLogs,
      selectedDate: selectedDate ?? this.selectedDate,
      period: period ?? this.period,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [weeklyTotals, selectedDayLogs, selectedDate, period, isLoading];
}
