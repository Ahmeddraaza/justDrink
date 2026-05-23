import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'history_state.dart';
import '../../../data/database/daos/water_log_dao.dart';
import '../../../shared/cubits/widget_sync/widget_sync_cubit.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final WaterLogDao waterLogDao;
  final WidgetSyncCubit widgetSyncCubit;
  StreamSubscription? _logsSubscription;

  HistoryCubit({
    required this.waterLogDao,
    required this.widgetSyncCubit,
  }) : super(HistoryState(selectedDate: DateTime.now()));

  void initialize() {
    emit(state.copyWith(isLoading: true));
    _subscribeToLogs();
    emit(state.copyWith(isLoading: false));
  }

  void _subscribeToLogs() {
    _logsSubscription?.cancel();
    _logsSubscription = waterLogDao.watchLogsForDate(state.selectedDate).listen((logs) {
      emit(state.copyWith(selectedDayLogs: logs));
    });
    refreshTotals();
  }

  Future<void> refreshTotals() async {
    final List<DailyTotal> totals;
    if (state.period == HistoryPeriod.monthly) {
      totals = await waterLogDao.getLast30DaysTotals();
    } else {
      totals = await waterLogDao.getLast7DaysTotals();
    }
    emit(state.copyWith(weeklyTotals: totals));
  }

  Future<void> changePeriod(HistoryPeriod period) async {
    emit(state.copyWith(isLoading: true, period: period));
    await refreshTotals();
    emit(state.copyWith(isLoading: false));
  }

  void selectDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
    _subscribeToLogs();
  }

  Future<void> deleteLog(int id) async {
    await waterLogDao.deleteLogById(id);
    widgetSyncCubit.sync();
    await refreshTotals();
  }

  @override
  Future<void> close() {
    _logsSubscription?.cancel();
    return super.close();
  }
}
