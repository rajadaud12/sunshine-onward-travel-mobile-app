import 'package:equatable/equatable.dart';

abstract class ProfileSettingsState extends Equatable {
  const ProfileSettingsState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileSettingsState {}

class ProfileLoading extends ProfileSettingsState {}

class ProfileUpdated extends ProfileSettingsState {
  final String message;
  const ProfileUpdated({required this.message});
}

class ProfileError extends ProfileSettingsState {
  final String message;
  const ProfileError({required this.message});
  @override
  List<Object?> get props => [message];
}