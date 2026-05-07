import 'package:equatable/equatable.dart';

class NotificationState extends Equatable {
  final bool permissionGranted;
  final bool remindersActive;
  final List<String> scheduledTimes;
  final bool isLoading;

  const NotificationState({
    this.permissionGranted = false,
    this.remindersActive = false,
    this.scheduledTimes = const [],
    this.isLoading = false,
  });

  NotificationState copyWith({
    bool? permissionGranted,
    bool? remindersActive,
    List<String>? scheduledTimes,
    bool? isLoading,
  }) {
    return NotificationState(
      permissionGranted: permissionGranted ?? this.permissionGranted,
      remindersActive: remindersActive ?? this.remindersActive,
      scheduledTimes: scheduledTimes ?? this.scheduledTimes,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [permissionGranted, remindersActive, scheduledTimes, isLoading];
}
