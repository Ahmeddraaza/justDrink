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

class CustomVolumeEditScreen extends StatelessWidget {
  const CustomVolumeEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(
        userProfileDao: GetIt.I<UserProfileDao>(),
        notificationService: GetIt.I<NotificationService>(),
        preferencesService: GetIt.I<PreferencesService>(),
      )..initialize(),
      child: const _CustomVolumeEditView(),
    );
  }
}

class _CustomVolumeEditView extends StatefulWidget {
  const _CustomVolumeEditView();

  @override
  State<_CustomVolumeEditView> createState() => _CustomVolumeEditViewState();
}

class _CustomVolumeEditViewState extends State<_CustomVolumeEditView> {
  late TextEditingController _vol1Controller;
  late TextEditingController _vol2Controller;

  @override
  void initState() {
    super.initState();
    _vol1Controller = TextEditingController();
    _vol2Controller = TextEditingController();
  }

  @override
  void dispose() {
    _vol1Controller.dispose();
    _vol2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state.profile != null && _vol1Controller.text.isEmpty) {
          _vol1Controller.text = state.profile!.quickAdd1Ml.toString();
          _vol2Controller.text = state.profile!.quickAdd2Ml.toString();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Custom Volumes')),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              TextField(
                controller: _vol1Controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Button 1 Volume (ml)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _vol2Controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Button 2 Volume (ml)',
                  border: OutlineInputBorder(),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  final v1 = int.tryParse(_vol1Controller.text);
                  final v2 = int.tryParse(_vol2Controller.text);
                  if (v1 != null && v2 != null) {
                    await GetIt.I<UserProfileDao>().updateQuickAddVolumes(
                      quickAdd1Ml: v1,
                      quickAdd2Ml: v2,
                    );
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text('Save Volumes'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
