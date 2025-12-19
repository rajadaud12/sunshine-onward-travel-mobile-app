// booking_home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sot/core/config/app_colors.dart';
import 'package:sot/core/routes/app_routes.dart';
import 'package:sot/features/booking/presentation/widgets/booking_bottom_sheet.dart';
import 'package:sot/features/booking/presentation/widgets/booking_location_summary.dart';
import 'package:sot/features/booking/presentation/widgets/booking_map_view.dart';
import 'package:sot/features/booking/state/booking_cubit.dart';
import 'package:sot/features/booking/state/booking_state.dart';

class BookingHomePage extends StatefulWidget {
  const BookingHomePage({super.key});

  @override
  State<BookingHomePage> createState() => _BookingHomePageState();
}

class _BookingHomePageState extends State<BookingHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    context.read<BookingCubit>().setStep(BookingStep.location);
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _performSignOut(BuildContext ctx) async {
    final messenger = ScaffoldMessenger.of(ctx);
    try {
      await FirebaseAuth.instance.signOut();
      try {
        await GoogleSignIn().signOut();
      } catch (_) {
        // Ignore Google sign-out errors
      }
      if (ctx.mounted) {
        Navigator.pushNamedAndRemoveUntil(ctx, AppRoutes.welcome, (route) => false);
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

  Future<void> _confirmAndSignOut(BuildContext ctx) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dctx) {
        return AlertDialog(
          title: const Text('Sign out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(true),
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      if (ctx.mounted) await _performSignOut(ctx);
    }
  }

  Widget _buildInitialPlaceholder(String initial, {required double size}) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: AppColors.white,
          fontSize: size * 0.5, // Adjusted for better proportion
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get current Firebase User
    final user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? 'Guest User';
    final String userEmail = user?.email ?? 'No Email';
    final String? userPhotoUrl = user?.photoURL;

    // Get the first letter of the name for the placeholder
    final String userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return BlocConsumer<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
          context.read<BookingCubit>().clearError();
        }
      },
      builder: (context, state) {
        final showRouteInfo = state.locations.length >= 2 &&
            state.locations.every((loc) => loc != null) &&
            state.distanceMiles != null &&
            state.estimatedTime != null;
        final allLocationsSet = state.locations.isNotEmpty && state.locations.every((loc) => loc != null);

        double initialChildSize = 0.5;
        switch (state.currentStep) {
          case BookingStep.location:
            final len = state.locations.length;
            initialChildSize = 0.40 + 0.05 * (len - 2).clamp(0, 3);
            break;
          case BookingStep.dateTime:
            initialChildSize = 0.65;
            break;
          case BookingStep.selectRide:
            initialChildSize = 0.60;
            break;
          default:
            initialChildSize = 0.5;
        }

        return Scaffold(
          key: _scaffoldKey,
          drawer: Drawer(
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
            ),
            backgroundColor: AppColors.white,
            child: Column(
              children: [
                // --- Sleek Profile Header ---
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: userPhotoUrl == null ? AppColors.primary : AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: userPhotoUrl != null
                              ? Image.network(
                            userPhotoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildInitialPlaceholder(userInitial, size: 56),
                          )
                              : _buildInitialPlaceholder(userInitial, size: 56),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                color: AppColors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userEmail,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                                fontFamily: 'Poppins',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider after header
                const Divider(height: 1, color: Color(0xFFEEEEEE)),

                // --- Menu Items ---
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    children: [
                      _buildDrawerItem(
                        icon: Icons.history,
                        label: 'My Bookings',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.bookings);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Profile',
                        onTap: () {
                          Navigator.pop(context); // Close Drawer
                          Navigator.pushNamed(context, AppRoutes.profile);
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                      ),
                      _buildDrawerItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & Support',
                        onTap: () => Navigator.pop(context),
                      ),
                      _buildDrawerItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        onTap: () {
                          Navigator.pop(context); // Close Drawer
                          Navigator.pushNamed(context, AppRoutes.settings);
                        },
                      ),
                    ],
                  ),
                ),

                // --- Bottom Logout Section ---
                Container(
                  padding: const EdgeInsets.all(24),
                  child: SafeArea(
                    top: false,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _confirmAndSignOut(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                            SizedBox(width: 12),
                            Text(
                              'Log Out',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              const BookingMapView(),
              // Top Buttons (Menu & Profile Icon)
              if (state.currentStep == BookingStep.location || state.currentStep == BookingStep.dateTime)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Menu Button
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                          icon: const Icon(Icons.menu, color: AppColors.white, size: 20),
                        ),
                      ),

                      // Route Info (Center)
                      if (showRouteInfo)
                        Expanded(
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${state.distanceMiles!.toStringAsFixed(1)} mi • ${state.estimatedTime!.inMinutes} min',
                                style: const TextStyle(
                                  color: AppColors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Profile Icon (Right)
                      GestureDetector(
                        onTap: () => _scaffoldKey.currentState!.openDrawer(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: userPhotoUrl == null ? AppColors.primary : AppColors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: userPhotoUrl != null
                                ? Image.network(
                              userPhotoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildInitialPlaceholder(userInitial, size: 44),
                            )
                                : _buildInitialPlaceholder(userInitial, size: 44),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if ((state.currentStep == BookingStep.location || state.currentStep == BookingStep.dateTime) && allLocationsSet)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 80,
                  left: 20,
                  right: 20,
                  child: BookingLocationSummary(state: state),
                ),
              if (state.currentStep != null)
                DraggableScrollableSheet(
                  key: ValueKey(state.currentStep),
                  initialChildSize: initialChildSize,
                  minChildSize: 0.25,
                  maxChildSize: initialChildSize,
                  builder: (BuildContext context, ScrollController scrollController) {
                    return BookingBottomSheet(state: state, scrollController: scrollController);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87, size: 22),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      horizontalTitleGap: 4,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
    );
  }
}