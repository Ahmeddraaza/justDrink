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
      appBar: AppBar(
        title: Text('Settings', style: AppTextStyles.h2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
            padding: const EdgeInsets.all(24),
            children: [
              _SectionHeader(title: 'Hydration'),
              _SettingTile(
                title: 'Daily Goal',
                trailing: '${profile.dailyGoalMl} ml',
                onTap: () => _showGoalEditDialog(context, profile.dailyGoalMl),
              ),
              _SettingTile(
                title: 'Weight',
                trailing: '${profile.weightKg} kg',
                onTap: () => _showWeightEditDialog(context, profile.weightKg),
              ),
              const SizedBox(height: 32),
              _SectionHeader(title: 'Reminders'),
              SwitchListTile(
                title: Text('Enable Reminders', style: AppTextStyles.bodyMedium),
                value: profile.remindersEnabled,
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => context.read<SettingsCubit>().toggleReminders(val),
              ),
              _SettingTile(
                title: 'Daily Frequency',
                trailing: '${profile.reminderCount} times',
                onTap: () => _showFrequencyDialog(context, profile.reminderCount, profile.isPremium),
              ),
              PremiumGateWidget(
                child: _SettingTile(
                  title: 'Custom Reminder Text',
                  trailing: profile.customNotificationText ?? 'Default',
                  onTap: () => context.push(Routes.customNotifText),
                ),
              ),
              const SizedBox(height: 32),
              _SectionHeader(title: 'App'),
              PremiumGateWidget(
                child: _SettingTile(
                  title: 'Custom Log Volumes',
                  trailing: 'Edit',
                  onTap: () => context.push(Routes.customVolume),
                ),
              ),
              _SettingTile(
                title: 'Privacy Policy',
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () {}, // Link to web
              ),
              const SizedBox(height: 40),
              if (!profile.isPremium)
                ElevatedButton(
                  onPressed: () => context.push(Routes.paywall),
                  child: const Text('Upgrade to PRO'),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showGoalEditDialog(BuildContext context, int current) {
    final controller = TextEditingController(text: current.toString());
    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        title: const Text('Edit Daily Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: 'ml'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dContext), child: const Text('Cancel')),
          TextButton(
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
        title: const Text('Edit Weight'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: 'kg'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dContext), child: const Text('Cancel')),
          TextButton(
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
        title: const Text('Reminder Frequency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [4, 6, 8, 10, 12].map((count) {
            final isLocked = count > 6 && !isPremium;
            return ListTile(
              title: Text('$count times per day'),
              trailing: isLocked ? const Icon(Icons.lock, size: 16) : null,
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final dynamic trailing;
  final VoidCallback onTap;

  const _SettingTile({
    required this.title,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: AppTextStyles.bodyMedium),
      trailing: trailing is Widget
          ? trailing
          : Text(trailing.toString(),
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}
