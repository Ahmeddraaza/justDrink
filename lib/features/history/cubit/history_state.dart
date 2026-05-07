import 'package:equatable/equatable.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/daos/water_log_dao.dart';

class HistoryState extends Equatable {
  final List<DailyTotal> weeklyTotals;
  final List<WaterLog> selectedDayLogs;
  final DateTime selectedDate;
  final bool isLoading;

  const HistoryState({
    this.weeklyTotals = const [],
    this.selectedDayLogs = const [],
    required this.selectedDate,
    this.isLoading = false,
  });

  HistoryState copyWith({
    List<DailyTotal>? weeklyTotals,
    List<WaterLog>? selectedDayLogs,
    DateTime? selectedDate,
    bool? isLoading,
  }) {
    return HistoryState(
      weeklyTotals: weeklyTotals ?? this.weeklyTotals,
      selectedDayLogs: selectedDayLogs ?? this.selectedDayLogs,
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [weeklyTotals, selectedDayLogs, selectedDate, isLoading];
}
