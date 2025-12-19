import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sot/core/utils/api_service.dart';
import 'package:sot/features/profile_settings/presentation/state/profile_settings_state.dart';

class ProfileSettingsCubit extends Cubit<ProfileSettingsState> {
  ProfileSettingsCubit() : super(ProfileInitial());

  Future<void> updateProfile({
    required String name,
    File? imageFile,
  }) async {
    emit(ProfileLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(const ProfileError(message: "User not logged in"));
        return;
      }

      String? photoUrl;

      // 1. Upload Image to Storage (Client-side is best for file streams)
      if (imageFile != null) {
        try {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('user_profiles')
              .child('${user.uid}.jpg');

          await storageRef.putFile(imageFile);
          photoUrl = await storageRef.getDownloadURL();
        } catch (e) {
          emit(ProfileError(message: "Image upload failed: $e"));
          return;
        }
      }

      // 2. Call Backend API to update Database & Auth
      // We send only the data strings to the backend
      final Map<String, dynamic> payload = {
        'name': name,
        if (photoUrl != null) 'photoURL': photoUrl,
      };

      final response = await ApiService.put('/users/profile', payload); // Note: PUT method

      if (response.statusCode == 200) {
        // 3. Force reload local user to update UI immediately
        await user.reload();
        emit(const ProfileUpdated(message: "Profile updated successfully"));
      } else {
        emit(ProfileError(message: "Server error: ${response.body}"));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
}