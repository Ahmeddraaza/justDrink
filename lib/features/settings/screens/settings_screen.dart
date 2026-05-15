import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/database/daos/user_profile_dao.dart';
import '../../../services/notification_service.dart';
import '../../../data/preferences/preferences_service.dart';
import '../../../shared/widgets/premium_gate_widget.dart';
import '../../../shared/widgets/banner_ad_widget.dart';
import '../widgets/settings_header.dart';
import '../widgets/settings_card.dart';
import '../../../services/widget_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(
        userProfileDao: GetIt.I<UserProfileDao>(),
        notificationService: GetIt.I<NotificationService>(),
        preferencesService: GetIt.I<PreferencesService>(),
      )..initialize(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Settings', style: AppTextStyles.h2.copyWith(color: AppColors.heading)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.heading),
          onPressed: () => context.go(Routes.dashboard),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final profile = state.profile;
          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            children: [
              GestureDetector(
                onTap: profile.isPremium ? null : () => context.push(Routes.paywall),
                child: SettingsHeader(
                  dailyGoal: profile.dailyGoalMl,
                  weight: profile.weightKg,
                  isPremium: profile.isPremium,
                ),
              ),
              const SizedBox(height: 32),
              _SectionHeader(title: 'Hydration'),
              SettingsCard(
                title: 'Daily Goal',
                subtitle: '${profile.dailyGoalMl} ml',
                icon: Icons.track_changes,
                onTap: () => _showGoalEditDialog(context, profile.dailyGoalMl),
              ),
              SettingsCard(
                title: 'Weight',
                subtitle: '${profile.weightKg} kg',
                icon: Icons.monitor_weight_outlined,
                onTap: () => _showWeightEditDialog(context, profile.weightKg),
              ),
              const SizedBox(height: 16),
              _SectionHeader(title: 'Reminders'),
              SettingsCard(
                title: 'Notifications',
                subtitle: profile.remindersEnabled ? 'Enabled' : 'Disabled',
                icon: Icons.notifications_none_outlined,
                onTap: () {},
                trailing: Switch.adaptive(
                  value: profile.remindersEnabled,
                  onChanged: (val) => context.read<SettingsCubit>().toggleReminders(val),
                  activeColor: AppColors.primary,
                ),
              ),
              SettingsCard(
                title: 'Daily Frequency',
                subtitle: '${profile.reminderCount} times per day',
                icon: Icons.repeat_rounded,
                onTap: () => _showFrequencyDialog(context, profile.reminderCount, profile.isPremium),
              ),
              PremiumGateWidget(
                child: SettingsCard(
                  title: 'Custom Reminder Text',
                  subtitle: profile.customNotificationText ?? 'Default message',
                  icon: Icons.edit_notifications_outlined,
                  onTap: () => context.push(Routes.customNotifText),
                ),
              ),
              const SizedBox(height: 16),
              _SectionHeader(title: 'App Settings'),
              if (!state.isWidgetAdded)
                SettingsCard(
                  title: 'Add Widget',
                  subtitle: 'Add JustDrink to your home screen',
                  icon: Icons.widgets_outlined,
                  onTap: () => _onAddWidget(context),
                ),
              PremiumGateWidget(
                child: SettingsCard(
                  title: 'Custom Log Volumes',
                  subtitle: 'Modify your quick add amounts',
                  icon: Icons.liquor_outlined,
                  onTap: () => context.push(Routes.customVolume),
                ),
              ),
              SettingsCard(
                title: 'Privacy Policy',
                subtitle: 'View how we handle your data',
                icon: Icons.privacy_tip_outlined,
                onTap: () {}, // Link to web
              ),
              const SizedBox(height: 32),
              const BannerAdWidget(),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Version 1.0.0',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.body.withOpacity(0.5)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onAddWidget(BuildContext context) async {
    // 1. Mark as added in state (hides button)
    context.read<SettingsCubit>().markWidgetAdded();

    // 2. Platform specific action
    try {
      final widgetService = GetIt.I<WidgetService>();
      await widgetService.requestPinWidget();
      
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        if (context.mounted) {
          _showIOSWidgetGuide(context);
        }
      }
    } catch (e) {
      debugPrint('Error pinning widget: $e');
    }
  }

  void _showIOSWidgetGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text('Add Widget to Home Screen', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            _GuideStep(number: '1', text: 'Go to your Home Screen and long press on any empty area.'),
            _GuideStep(number: '2', text: 'Tap the (+) button in the top left corner.'),
            _GuideStep(number: '3', text: 'Search for "JustDrink" and select your preferred widget size.'),
            _GuideStep(number: '4', text: 'Tap "Add Widget" to place it on your screen.'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dashboardBackground,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('GOT IT'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showGoalEditDialog(BuildContext context, int current) {
    final controller = TextEditingController(text: current.toString());
    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        title: Text('Daily Goal', style: AppTextStyles.h3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            suffixText: 'ml',
            border: UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dContext), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null) {
                context.read<SettingsCubit>().updateGoal(val);
                Navigator.pop(dContext);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showWeightEditDialog(BuildContext context, double current) {
    final controller = TextEditingController(text: current.toString());
    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        title: Text('Your Weight', style: AppTextStyles.h3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            suffixText: 'kg',
            border: UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dContext), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null) {
                context.read<SettingsCubit>().updateWeight(val);
                Navigator.pop(dContext);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showFrequencyDialog(BuildContext context, int current, bool isPremium) {
    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        title: Text('Reminder Frequency', style: AppTextStyles.h3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [4, 6, 8, 10, 12].map((count) {
            final isLocked = count > 6 && !isPremium;
            final isSelected = count == current;
            return ListTile(
              title: Text('$count times per day', style: AppTextStyles.bodyMedium),
              trailing: isLocked ? const Icon(Icons.lock, size: 16) : (isSelected ? const Icon(Icons.check, color: AppColors.primary) : null),
              onTap: isLocked ? null : () {
                context.read<SettingsCubit>().updateReminderCount(count);
                Navigator.pop(dContext);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  final String number;
  final String text;
  const _GuideStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(text, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.body)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
