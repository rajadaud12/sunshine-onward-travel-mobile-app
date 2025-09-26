import 'package:flutter/material.dart';
import 'package:sot/core/routes/app_routes.dart';
import 'package:sot/features/auth/presentation/pages/create_password_page.dart';
import 'package:sot/features/auth/presentation/pages/otp_page.dart';
import 'package:sot/features/auth/presentation/pages/sign_in_page.dart';
import 'package:sot/features/auth/presentation/pages/sign_up_page.dart';
import 'package:sot/features/booking/presentation/pages/booking_home_page.dart';
import 'package:sot/features/booking/presentation/pages/booking_summary_page.dart';
import 'package:sot/features/booking/presentation/pages/payment_method_page.dart';
import 'package:sot/features/booking/presentation/widgets/booking_location_summary.dart';
import 'package:sot/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:sot/features/auth/presentation/pages/welcome_page.dart';


/// Handles navigation between screens
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());

      case AppRoutes.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());

      case AppRoutes.signIn:
        return MaterialPageRoute(builder: (_) => const SignInPage());

      case AppRoutes.signUp:
        return MaterialPageRoute(builder: (_) => const SignUpPage());

      case AppRoutes.otp:
        return MaterialPageRoute(builder: (_) => const OtpPage());

      case AppRoutes.createPassword:
        return MaterialPageRoute(builder: (_) => const CreatePasswordPage());

      case AppRoutes.bookingHome:
        return MaterialPageRoute(builder: (_) => const BookingHomePage());

      case AppRoutes.bookingSummary:
        return MaterialPageRoute(builder: (_) => const BookingSummaryPage());

      case AppRoutes.paymentMethod:
        return MaterialPageRoute(builder: (_) => const PaymentMethodPage());




      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text("Profile Page"))),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Route not found")),
          ),
        );
    }
  }
}