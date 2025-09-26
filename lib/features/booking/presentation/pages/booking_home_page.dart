import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sot/core/config/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: Drawer(
            // remove elevation (no dropshadow) and ensure no border radius
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            backgroundColor: AppColors.white,
            child: SafeArea(
              child: Column(
                children: [
                  // Custom header container (no bottom border/line)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    color: AppColors.white, // same as drawer background to avoid any line effect
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

                  // Menu items
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        // Use subtle spacing and consistent dividers to keep it elegant
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
                          },
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        ListTile(
                          leading: const Icon(Icons.chat, color: AppColors.primary),
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
              // Top buttons positioned over the map
              Positioned(
                top: MediaQuery.of(context).padding.top + 20,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Sidebar menu button - fully circular
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
                    // Profile picture
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
              if ((state.currentStep == BookingStep.dateTime) || (state.currentStep == BookingStep.selectRide))
                Positioned(
                  top: MediaQuery.of(context).padding.top + 80,
                  left: 20,
                  right: 20,
                  child: BookingLocationSummary(state: state),
                ),
              if (state.currentStep != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BookingBottomSheet(state: state),
                ),
            ],
          ),
        );
      },
    );
  }
}
