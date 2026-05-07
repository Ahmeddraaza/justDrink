import 'package:equatable/equatable.dart';

class WidgetSyncState extends Equatable {
  final bool isSyncing;
  final DateTime? lastSyncedAt;
  final bool syncError;

  const WidgetSyncState({
    this.isSyncing = false,
    this.lastSyncedAt,
    this.syncError = false,
  });

  WidgetSyncState copyWith({
    bool? isSyncing,
    DateTime? lastSyncedAt,
    bool? syncError,
  }) {
    return WidgetSyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      syncError: syncError ?? this.syncError,
    );
  }

  @override
  List<Object?> get props => [isSyncing, lastSyncedAt, syncError];
}
