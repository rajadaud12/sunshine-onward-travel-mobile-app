import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sot/core/config/app_colors.dart';
import 'package:sot/core/routes/app_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Key to force refresh when coming back from Settings
  Key _refreshKey = UniqueKey();

  void _refreshProfile() {
    setState(() {
      _refreshKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: _ProfileView(key: _refreshKey, onEditProfile: _refreshProfile),
    );
  }
}

class _ProfileView extends StatefulWidget {
  final VoidCallback onEditProfile;
  const _ProfileView({super.key, required this.onEditProfile});

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? 'Guest User';
    final String userEmail = user?.email ?? 'No Email';
    final String? userPhotoUrl = user?.photoURL;
    final String userInitial =
    userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Column(
      children: [
        // 1. Red Header
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).padding.top + 100, // Fixed height header
          color: AppColors.primary,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            bottom: 40, // Extra bottom padding for the text
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: AppColors.black, size: 20),
                ),
              ),

              const SizedBox(width: 36), // Balance
            ],
          ),
        ),

        // 2. Overlapping Content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Negative margin pulls the avatar up into the red header
                Transform.translate(
                  offset: const Offset(0, -50),
                  child: Column(
                    children: [
                      // Avatar
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: userPhotoUrl == null
                                    ? AppColors.white
                                    : Colors.grey[200],
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: userPhotoUrl != null
                                    ? Image.network(
                                  userPhotoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) =>
                                      _buildInitial(userInitial, 120),
                                )
                                    : Container(
                                  color: AppColors.primary,
                                  child: _buildInitial(userInitial, 120),
                                ),
                              ),
                            ),
                            // Edit Icon

                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(userName,
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      const SizedBox(height: 4),
                      Text(userEmail,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.grey[600])),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Menu Options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildOptionTile(
                            context: context,
                            icon: Icons.edit_outlined,
                            title: 'Edit Profile',
                            onTap: () async {
                              await Navigator.pushNamed(
                                  context, AppRoutes.settings);
                              widget.onEditProfile();
                            }),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        _buildOptionTile(
                            context: context,
                            icon: Icons.history_rounded,
                            title: 'Ride History',
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.bookings);
                            }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitial(String char, double size) {
    return Center(
      child: Text(
        char,
        style: TextStyle(
            fontSize: size * 0.4,
            color: AppColors.white,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildOptionTile(
      {required BuildContext context,
        required IconData icon,
        required String title,
        required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              fontFamily: 'Poppins')),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
    );
  }
}