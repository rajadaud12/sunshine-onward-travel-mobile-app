import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sot/core/config/app_theme.dart';
import 'package:sot/core/routes/app_router.dart';
import 'package:sot/core/routes/app_routes.dart';
import 'package:sot/features/booking/state/booking_cubit.dart'; // Adjust path if needed

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BookingCubit>(
          create: (context) => BookingCubit(),
        ),
        // Add other BlocProviders here as needed in the future
        // Example: BlocProvider<AuthCubit>(create: (context) => AuthCubit()),
        // Example: BlocProvider<ProfileCubit>(create: (context) => ProfileCubit()),
      ],
      child: MaterialApp(
        title: "Sunshine Onward Travel",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        initialRoute: AppRoutes.onboarding,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}