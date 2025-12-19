import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sot/core/config/app_colors.dart';
import 'package:sot/core/widgets/buttons.dart';
import 'package:sot/core/widgets/custom_text_field.dart';
import 'package:sot/features/profile_settings/presentation/state/profile_settings_cubit.dart';
import 'package:sot/features/profile_settings/presentation/state/profile_settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the Cubit specifically for this page
    return BlocProvider(
      create: (context) => ProfileSettingsCubit(),
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _nameController = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    _nameController.text = user?.displayName ?? '';
  }

  // --- FIXED IMAGE PICKER FUNCTION ---
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75, // Optimize image size
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Image Picker Error: $e"); // Log error to console
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')), // Show actual error to user
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final currentPhotoUrl = user?.photoURL;

    return BlocConsumer<ProfileSettingsCubit, ProfileSettingsState>(
      listener: (context, state) {
        if (state is ProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          Navigator.pop(context);
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final bool isLoading = state is ProfileLoading;

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: AppColors.white, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back,
                    color: AppColors.black, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Edit Profile',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // --- Image Picker ---
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.primary, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: _imageFile != null
                                ? Image.file(_imageFile!, fit: BoxFit.cover)
                                : (currentPhotoUrl != null
                                ? Image.network(currentPhotoUrl,
                                fit: BoxFit.cover)
                                : const Icon(Icons.person,
                                size: 50, color: Colors.grey)),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              height: 32,
                              width: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _pickImage,
                    child: const Text('Change Profile Picture',
                        style: TextStyle(color: AppColors.primary)),
                  ),
                  const SizedBox(height: 24),

                  // --- Form ---
                  const Align(
                    alignment: Alignment.centerLeft,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Full Name',
                    hintText: 'Enter your name',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 20),

                  const SizedBox(height: 40),

                  isLoading
                      ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary))
                      : CustomButton(
                    text: 'Save Changes',
                    onPressed: () {
                      if (_nameController.text.trim().isEmpty) return;
                      context.read<ProfileSettingsCubit>().updateProfile(
                        name: _nameController.text.trim(),
                        imageFile: _imageFile,
                      );
                    },
                    color: AppColors.primary,
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}