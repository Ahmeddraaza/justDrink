import 'package:equatable/equatable.dart';
import '../../../data/database/app_database.dart';

class SettingsState extends Equatable {
  final UserProfileData? profile;
  final bool isPremium;
  final bool isLoading;
  final String? errorMessage;

  const SettingsState({
    this.profile,
    this.isPremium = false,
    this.isLoading = false,
    this.errorMessage,
  });

  SettingsState copyWith({
    UserProfileData? profile,
    bool? isPremium,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SettingsState(
      profile: profile ?? this.profile,
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [profile, isPremium, isLoading, errorMessage];
}
