// lib/main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sot/core/config/app_theme.dart';
import 'package:sot/core/routes/app_router.dart';
import 'package:sot/core/routes/app_routes.dart';
import 'package:sot/features/booking/state/booking_cubit.dart';
import 'package:sot/features/booking_history/state/booking_history_cubit.dart';
import 'package:sot/features/auth/state/auth_cubit.dart'; // Optional, if you want to include AuthCubit

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final initialRoute = FirebaseAuth.instance.currentUser != null ? AppRoutes.bookingHome : AppRoutes.onboarding;
    return MultiBlocProvider(
      providers: [
        BlocProvider<BookingCubit>(
          create: (context) => BookingCubit(googleMapsApiKey: 'AIzaSyCPhfNzOVaHkHU7ewiwJGUvf8CxtYD3Mz8'),
        ),
        BlocProvider<BookingHistoryCubit>(
          create: (context) => BookingHistoryCubit(),
        ),
        // Optionally add AuthCubit if you're integrating authentication
        BlocProvider<AuthCubit>(  // Add this for shared auth state
          create: (context) => AuthCubit(),
        ),
        // Add other BlocProviders here as needed in the future
        // Example: BlocProvider<ProfileCubit>(create: (context) => ProfileCubit()),
      ],
      child: MaterialApp(
        title: "Sunshine Onward Travel",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        initialRoute: initialRoute,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}