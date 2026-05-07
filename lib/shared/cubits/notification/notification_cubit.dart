import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_state.dart';
import '../../../services/notification_service.dart';
import '../../../data/database/app_database.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationService notificationService;

  NotificationCubit({required this.notificationService})
      : super(const NotificationState());

  Future<void> checkPermissionStatus() async {
    final granted = await notificationService.checkPermission();
    emit(state.copyWith(permissionGranted: granted));
  }

  Future<void> requestPermission() async {
    final granted = await notificationService.requestPermission();
    emit(state.copyWith(permissionGranted: granted));
  }

  Future<void> scheduleReminders(UserProfileData profile) async {
    emit(state.copyWith(isLoading: true));
    await notificationService.rescheduleAll(profile);
    // Ideally NotificationService would return the scheduled times
    emit(state.copyWith(isLoading: false, remindersActive: profile.remindersEnabled));
  }

  Future<void> cancelAllReminders() async {
    await notificationService.cancelAll();
    emit(state.copyWith(remindersActive: false));
  }
}
