import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_state.dart';
import '../../../data/database/daos/water_log_dao.dart';
import '../../../data/database/daos/user_profile_dao.dart';
import '../../../data/preferences/preferences_service.dart';
import '../../../shared/cubits/ad/ad_cubit.dart';
import '../../../shared/cubits/widget_sync/widget_sync_cubit.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final WaterLogDao waterLogDao;
  final UserProfileDao userProfileDao;
  final PreferencesService preferencesService;
  final AdCubit adCubit;
  final WidgetSyncCubit widgetSyncCubit;

  StreamSubscription? _totalSubscription;
  StreamSubscription? _logsSubscription;
  StreamSubscription? _profileSubscription;
  Timer? _undoTimer;

  DashboardCubit({
    required this.waterLogDao,
    required this.userProfileDao,
    required this.preferencesService,
    required this.adCubit,
    required this.widgetSyncCubit,
  }) : super(const DashboardState());

  void initialize() {
    emit(state.copyWith(isLoading: true));
    
    _totalSubscription = waterLogDao.watchTodayTotalMl().listen((total) {
      emit(state.copyWith(currentIntakeMl: total));
    });

    _logsSubscription = waterLogDao.watchTodayLogs().listen((logs) {
      emit(state.copyWith(todayLogs: logs));
    });

    _profileSubscription = userProfileDao.watchProfile().listen((profile) {
      if (profile != null) {
        emit(state.copyWith(
          dailyGoalMl: profile.dailyGoalMl,
          quickAdd1Ml: profile.quickAdd1Ml,
          quickAdd2Ml: profile.quickAdd2Ml,
          isPremium: profile.isPremium,
        ));
      }
    });

    _loadAdCounter();
    emit(state.copyWith(
      isLoading: false,
      isWidgetAdded: preferencesService.isWidgetAdded,
    ));
  }

  Future<void> _loadAdCounter() async {
    final count = preferencesService.getInt('ad_log_counter') ?? 0;
    emit(state.copyWith(appLogCountToday: count));
  }

  Future<void> logWater(int amountMl) async {
    final id = await waterLogDao.logWater(amountMl: amountMl, source: 'app');
    
    // Handle ad logic
    if (!state.isPremium) {
      final newCount = await preferencesService.getAndIncrementAdCounter();
      emit(state.copyWith(appLogCountToday: newCount));
      if (newCount % 3 == 0) {
        adCubit.showInterstitial();
      }
    }

    emit(state.copyWith(showUndo: true, lastLoggedId: id));
    widgetSyncCubit.sync();

    _undoTimer?.cancel();
    _undoTimer = Timer(const Duration(seconds: 5), () {
      emit(state.copyWith(showUndo: false));
    });
  }

  Future<void> undoLastLog() async {
    if (state.lastLoggedId != null) {
      await waterLogDao.deleteLogById(state.lastLoggedId!);
      emit(state.copyWith(showUndo: false, lastLoggedId: null));
      widgetSyncCubit.sync();
    }
  }

  Future<void> markWidgetAdded() async {
    await preferencesService.setIsWidgetAdded(true);
    emit(state.copyWith(isWidgetAdded: true));
  }

  @override
  Future<void> close() {
    _totalSubscription?.cancel();
    _logsSubscription?.cancel();
    _profileSubscription?.cancel();
    _undoTimer?.cancel();
    return super.close();
  }
}
