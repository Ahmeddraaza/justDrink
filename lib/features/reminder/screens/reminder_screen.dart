import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/banner_ad_widget.dart';
import '../../../shared/widgets/floating_navbar.dart';
import '../../../core/constants/route_constants.dart';
import '../../../data/database/daos/user_profile_dao.dart';
import '../../../data/database/app_database.dart';
import '../../../core/utils/notification_scheduler.dart';
import '../../../services/notification_service.dart';
import '../widgets/reminder_header.dart';
import '../widgets/reminder_tile.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfileData?>(
      stream: GetIt.I<UserProfileDao>().watchProfile(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final profile = snapshot.data!;
        
        // Generate actual reminders dynamically strictly from their routine!
        final tzTimes = NotificationScheduler.generate(
          wakeTime: profile.wakeTime,
          sleepTime: profile.sleepTime,
          count: profile.remindersEnabled ? profile.reminderCount : 0,
        );

        final List<TimeOfDay> reminders = tzTimes
            .map((t) => TimeOfDay(hour: t.hour, minute: t.minute))
            .toList();

        String nextTime = '--:--';
        final now = TimeOfDay.now();
        final nowMinutes = now.hour * 60 + now.minute;

        if (reminders.isNotEmpty && profile.remindersEnabled) {
          reminders.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
          final next = reminders.firstWhere(
            (t) => (t.hour * 60 + t.minute) > nowMinutes,
            orElse: () => reminders.first,
          );
          nextTime = next.format(context);
        }

        return Scaffold(
          backgroundColor: Colors.white,
          extendBody: true,
          appBar: AppBar(
            title: Text('Reminders', style: AppTextStyles.h2.copyWith(color: AppColors.heading)),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.settings_outlined, color: AppColors.heading),
              onPressed: () => context.push(Routes.settings),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 28, color: AppColors.primary),
                onPressed: () => _addReminderFrequency(context, profile),
              ),
              const SizedBox(width: 8),
            ],
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BannerAdWidget(),
              const FloatingNavbar(activeRoute: Routes.reminder),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
            children: [
              ReminderHeader(
                totalReminders: reminders.length,
                nextReminderTime: nextTime,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Schedule',
                    style: AppTextStyles.h3.copyWith(color: AppColors.heading),
                  ),
                  Text(
                    'Dynamic Frequency',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...reminders.asMap().entries.map((entry) {
                final index = entry.key;
                final time = entry.value;
                return ReminderTile(
                  time: time,
                  isActive: profile.remindersEnabled,
                  onToggle: (val) => _toggleReminders(context, val),
                  onTap: () => _showRoutineGuide(context),
                  onDelete: () => _removeReminderFrequency(context, profile),
                );
              }),
              if (reminders.isEmpty || !profile.remindersEnabled)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 48,
                          color: AppColors.body.withOpacity(0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          profile.remindersEnabled
                              ? 'Frequency set to 0. Add a reminder above!'
                              : 'Reminders are disabled. Enable in Settings!',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.body),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleReminders(BuildContext context, bool enabled) async {
    await GetIt.I<UserProfileDao>().updateRemindersEnabled(enabled);
    final updatedProfile = await GetIt.I<UserProfileDao>().getProfile();
    if (updatedProfile != null) {
      await GetIt.I<NotificationService>().rescheduleAll(updatedProfile);
    }
  }

  Future<void> _addReminderFrequency(BuildContext context, UserProfileData profile) async {
    final newCount = profile.reminderCount + 1;
    if (!profile.isPremium && newCount > 6) {
      // Direct user to paywall if they exceed free limit (6 reminders/day)
      context.push(Routes.paywall);
    } else {
      await GetIt.I<UserProfileDao>().updateReminderCount(newCount);
      final updatedProfile = await GetIt.I<UserProfileDao>().getProfile();
      if (updatedProfile != null) {
        await GetIt.I<NotificationService>().rescheduleAll(updatedProfile);
      }
    }
  }

  Future<void> _removeReminderFrequency(BuildContext context, UserProfileData profile) async {
    if (profile.reminderCount > 0) {
      final newCount = profile.reminderCount - 1;
      await GetIt.I<UserProfileDao>().updateReminderCount(newCount);
      final updatedProfile = await GetIt.I<UserProfileDao>().getProfile();
      if (updatedProfile != null) {
        await GetIt.I<NotificationService>().rescheduleAll(updatedProfile);
      }
    }
  }

  void _showRoutineGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Smart Reminders', style: AppTextStyles.h3),
        content: Text(
          'Your reminders are automatically and perfectly spaced based on your sleep/wake routine.\n\nTo customize these times, please adjust your Wake and Sleep times in Settings.',
          style: AppTextStyles.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.body)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.push(Routes.settings);
            },
            child: const Text('Go to Settings', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
