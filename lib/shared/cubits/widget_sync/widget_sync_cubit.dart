import 'package:flutter_bloc/flutter_bloc.dart';
import 'widget_sync_state.dart';
import '../../../services/widget_service.dart';
import '../../../data/database/daos/water_log_dao.dart';
import '../../../data/database/daos/user_profile_dao.dart';

class WidgetSyncCubit extends Cubit<WidgetSyncState> {
  final WidgetService widgetService;
  final WaterLogDao waterLogDao;
  final UserProfileDao userProfileDao;

  WidgetSyncCubit({
    required this.widgetService,
    required this.waterLogDao,
    required this.userProfileDao,
  }) : super(const WidgetSyncState());

  Future<void> sync() async {
    emit(state.copyWith(isSyncing: true));
    try {
      final total = await waterLogDao.getTodayTotalMl();
      final profile = await userProfileDao.getProfile();
      
      if (profile != null) {
        await widgetService.updateWidget(
          currentMl: total,
          goalMl: profile.dailyGoalMl,
          isPremium: profile.isPremium,
        );
      }
      emit(state.copyWith(isSyncing: false, lastSyncedAt: DateTime.now()));
    } catch (e) {
      emit(state.copyWith(isSyncing: false, syncError: true));
    }
  }

  Future<void> handleWidgetTap(int amountMl) async {
    await waterLogDao.logWater(amountMl: amountMl, source: 'widget');
    await sync();
  }
}
