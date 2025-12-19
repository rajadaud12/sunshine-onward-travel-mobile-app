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
      }
      Navigator.pushNamedAndRemoveUntil(ctx, AppRoutes.welcome, (route) => false);
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
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await _performSignOut(ctx);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        final hasBottomSheet = state.currentStep != null;
        final bottomOffset = hasBottomSheet ? 140.0 : 24.0;
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
              borderRadius: BorderRadius.zero,
            ),
            backgroundColor: AppColors.white,
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    color: AppColors.white,
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.network(
                              'https://via.placeholder.com/60x60/CCCCCC/FFFFFF?text=U',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.white,
                                  child: const Icon(
                                    Icons.person,
                                    color: AppColors.placeholder,
                                    size: 30,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'User Name',
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'user@example.com',
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.book, color: AppColors.primary),
                          title: const Text(
                            'Bookings',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, AppRoutes.bookings);
                          },
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        ListTile(
                          leading: const Icon(Icons.textsms_sharp, color: AppColors.primary),
                          title: const Text(
                            'Chat',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        ListTile(
                          leading: const Icon(Icons.help, color: AppColors.primary),
                          title: const Text(
                            'Help',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        ListTile(
                          leading: const Icon(Icons.settings, color: AppColors.primary),
                          title: const Text(
                            'Settings',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        ListTile(
                          leading: const Icon(Icons.article, color: AppColors.primary),
                          title: const Text(
                            'Terms and Conditions',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        ListTile(
                          leading: const Icon(Icons.privacy_tip, color: AppColors.primary),
                          title: const Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        // === Logout item in Drawer ===
                        ListTile(
                          leading: const Icon(Icons.logout, color: AppColors.primary),
                          title: const Text(
                            'Logout',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context); // close drawer
                            _confirmAndSignOut(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Stack(
            children: [
              const BookingMapView(),
              if (state.currentStep == BookingStep.location || state.currentStep == BookingStep.dateTime)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                          onPressed: () {
                            _scaffoldKey.currentState!.openDrawer();
                          },
                          icon: const Icon(
                            Icons.menu,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      if (showRouteInfo)
                        Expanded(
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.border),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${state.distanceMiles!.toStringAsFixed(1)} mi • ${state.estimatedTime!.inMinutes} min',
                                style: const TextStyle(
                                  color: AppColors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 2,
                          ),
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
                          child: Image.network(
                            'https://via.placeholder.com/44x44/CCCCCC/FFFFFF?text=U',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.white,
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.placeholder,
                                  size: 24,
                                ),
                              );
                            },
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
}