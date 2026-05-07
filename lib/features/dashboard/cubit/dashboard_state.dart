import 'package:equatable/equatable.dart';
import '../../../data/database/app_database.dart';

class DashboardState extends Equatable {
  final int currentIntakeMl;
  final int dailyGoalMl;
  final List<WaterLog> todayLogs;
  final int quickAdd1Ml;
  final int quickAdd2Ml;
  final bool isPremium;
  final bool showUndo;
  final int? lastLoggedId;
  final int appLogCountToday;
  final bool isLoading;

  const DashboardState({
    this.currentIntakeMl = 0,
    this.dailyGoalMl = 2500,
    this.todayLogs = const [],
    this.quickAdd1Ml = 250,
    this.quickAdd2Ml = 500,
    this.isPremium = false,
    this.showUndo = false,
    this.lastLoggedId,
    this.appLogCountToday = 0,
    this.isLoading = false,
  });

  DashboardState copyWith({
    int? currentIntakeMl,
    int? dailyGoalMl,
    List<WaterLog>? todayLogs,
    int? quickAdd1Ml,
    int? quickAdd2Ml,
    bool? isPremium,
    bool? showUndo,
    int? lastLoggedId,
    int? appLogCountToday,
    bool? isLoading,
  }) {
    return DashboardState(
      currentIntakeMl: currentIntakeMl ?? this.currentIntakeMl,
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      todayLogs: todayLogs ?? this.todayLogs,
      quickAdd1Ml: quickAdd1Ml ?? this.quickAdd1Ml,
      quickAdd2Ml: quickAdd2Ml ?? this.quickAdd2Ml,
      isPremium: isPremium ?? this.isPremium,
      showUndo: showUndo ?? this.showUndo,
      lastLoggedId: lastLoggedId ?? this.lastLoggedId,
      appLogCountToday: appLogCountToday ?? this.appLogCountToday,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        currentIntakeMl,
        dailyGoalMl,
        todayLogs,
        quickAdd1Ml,
        quickAdd2Ml,
        isPremium,
        showUndo,
        lastLoggedId,
        appLogCountToday,
        isLoading,
      ];
}
