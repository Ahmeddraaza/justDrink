import 'package:equatable/equatable.dart';
import '../../../data/database/app_database.dart';

class SettingsState extends Equatable {
  final UserProfileData? profile;
  final bool isPremium;
  final bool isLoading;
  final String? errorMessage;

  final bool isWidgetAdded;

  const SettingsState({
    this.profile,
    this.isPremium = false,
    this.isLoading = false,
    this.errorMessage,
    this.isWidgetAdded = false,
  });

  SettingsState copyWith({
    UserProfileData? profile,
    bool? isPremium,
    bool? isLoading,
    String? errorMessage,
    bool? isWidgetAdded,
  }) {
    return SettingsState(
      profile: profile ?? this.profile,
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isWidgetAdded: isWidgetAdded ?? this.isWidgetAdded,
    );
  }

  @override
  List<Object?> get props => [profile, isPremium, isLoading, errorMessage, isWidgetAdded];
}
