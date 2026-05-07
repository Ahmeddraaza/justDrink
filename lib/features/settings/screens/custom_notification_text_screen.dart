import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/database/daos/user_profile_dao.dart';
import '../../../services/notification_service.dart';
import '../../../data/preferences/preferences_service.dart';

class CustomNotificationTextScreen extends StatelessWidget {
  const CustomNotificationTextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(
        userProfileDao: GetIt.I<UserProfileDao>(),
        notificationService: GetIt.I<NotificationService>(),
        preferencesService: GetIt.I<PreferencesService>(),
      )..initialize(),
      child: const _CustomNotificationTextView(),
    );
  }
}

class _CustomNotificationTextView extends StatefulWidget {
  const _CustomNotificationTextView();

  @override
  State<_CustomNotificationTextView> createState() =>
      _CustomNotificationTextViewState();
}

class _CustomNotificationTextViewState
    extends State<_CustomNotificationTextView> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state.profile != null && _controller.text.isEmpty) {
          _controller.text =
              state.profile!.customNotificationText ?? 'Time to drink water!';
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Custom Reminder')),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                'What should we say to nudge you?',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                maxLength: 50,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g. Drink up, you sexy human!',
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  if (_controller.text.isNotEmpty) {
                    await context
                        .read<SettingsCubit>()
                        .updateCustomNotifText(_controller.text);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text('Update Reminder Text'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
