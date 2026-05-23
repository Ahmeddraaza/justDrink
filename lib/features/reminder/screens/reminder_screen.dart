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
import '../../../data/preferences/preferences_service.dart';
import '../../../core/utils/notification_scheduler.dart';
import '../../../services/notification_service.dart';
import '../widgets/reminder_header.dart';
import '../widgets/reminder_tile.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
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
        
        // We always calculate a beautifully distributed schedule of 10 reminders
        final tzTimes = NotificationScheduler.generate(
          wakeTime: profile.wakeTime,
          sleepTime: profile.sleepTime,
          count: 10,
        );

        final List<TimeOfDay> reminders = tzTimes
            .map((t) => TimeOfDay(hour: t.hour, minute: t.minute))
            .toList();

        // Calculate next reminder time strictly among the active ones
        final baseActiveReminders = profile.isPremium ? reminders : reminders.take(6).toList();
        
        // Filter out individually disabled reminders
        final disabledTimes = PreferencesService.instance.disabledReminderTimes;
        final activeReminders = baseActiveReminders.where((t) {
          final timeString = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
          return !disabledTimes.contains(timeString);
        }).toList();
        
        String nextTime = '--:--';
        final now = TimeOfDay.now();
        final nowMinutes = now.hour * 60 + now.minute;

        if (activeReminders.isNotEmpty && profile.remindersEnabled) {
          activeReminders.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
          final next = activeReminders.firstWhere(
            (t) => (t.hour * 60 + t.minute) > nowMinutes,
            orElse: () => activeReminders.first,
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
              icon: const Icon(Icons.menu, color: AppColors.heading, size: 28),
              onPressed: () => context.push(Routes.settings),
            ),
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
                totalReminders: activeReminders.length,
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
                    profile.isPremium ? '10 active reminders' : '6 active / 4 locked',
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
                final isLocked = !profile.isPremium && index >= 6;
                
                final hourStr = time.hour.toString().padLeft(2, '0');
                final minStr = time.minute.toString().padLeft(2, '0');
                final timeString = '$hourStr:$minStr';
                final isTileDisabled = PreferencesService.instance.disabledReminderTimes.contains(timeString);

                return ReminderTile(
                  time: time,
                  isActive: profile.remindersEnabled && !isLocked && !isTileDisabled,
                  isLocked: isLocked,
                  onToggle: (val) => _toggleSingleReminder(context, time, val),
                  onTap: () {
                    if (isLocked) {
                      context.push(Routes.paywall);
                    } else {
                      _showRoutineGuide(context);
                    }
                  },
                );
              }),
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

  Future<void> _toggleSingleReminder(BuildContext context, TimeOfDay time, bool enabled) async {
    final hourStr = time.hour.toString().padLeft(2, '0');
    final minStr = time.minute.toString().padLeft(2, '0');
    final timeString = '$hourStr:$minStr';
    
    final prefs = PreferencesService.instance;
    final currentDisabled = List<String>.from(prefs.disabledReminderTimes);
    
    if (enabled) {
      currentDisabled.remove(timeString);
    } else {
      if (!currentDisabled.contains(timeString)) {
        currentDisabled.add(timeString);
      }
    }
    
    await prefs.setDisabledReminderTimes(currentDisabled);
    
    if (mounted) {
      setState(() {});
    }
    
    final profile = await GetIt.I<UserProfileDao>().getProfile();
    if (profile != null) {
      await GetIt.I<NotificationService>().rescheduleAll(profile);
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
