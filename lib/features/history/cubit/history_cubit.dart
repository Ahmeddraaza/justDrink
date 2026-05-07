import 'package:flutter_bloc/flutter_bloc.dart';
import 'history_state.dart';
import '../../../data/database/daos/water_log_dao.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final WaterLogDao waterLogDao;

  HistoryCubit({required this.waterLogDao})
      : super(HistoryState(selectedDate: DateTime.now()));

  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true));
    await refresh();
    emit(state.copyWith(isLoading: false));
  }

  Future<void> refresh() async {
    final weekly = await waterLogDao.getLast7DaysTotals();
    final logs = await waterLogDao.getLogsForDate(state.selectedDate);
    emit(state.copyWith(weeklyTotals: weekly, selectedDayLogs: logs));
  }

  Future<void> selectDate(DateTime date) async {
    emit(state.copyWith(isLoading: true, selectedDate: date));
    final logs = await waterLogDao.getLogsForDate(date);
    emit(state.copyWith(selectedDayLogs: logs, isLoading: false));
  }

  Future<void> deleteLog(int id) async {
    await waterLogDao.deleteLogById(id);
    await refresh();
  }
}
