import 'package:equatable/equatable.dart';
import '../../../data/database/app_database.dart';

class SettingsState extends Equatable {
  final UserProfileData? profile;
  final bool isLoading;
  final String? errorMessage;
  final bool isWidgetAdded;

  const SettingsState({
    this.profile,
    this.isLoading = false,
    this.errorMessage,
    this.isWidgetAdded = false,
  });

  SettingsState copyWith({
    UserProfileData? profile,
    bool? isLoading,
    String? errorMessage,
    bool? isWidgetAdded,
  }) {
    return SettingsState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isWidgetAdded: isWidgetAdded ?? this.isWidgetAdded,
    );
  }

  @override
  List<Object?> get props => [profile, isLoading, errorMessage, isWidgetAdded];
}
