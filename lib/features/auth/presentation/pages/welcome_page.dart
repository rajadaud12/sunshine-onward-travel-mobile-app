// lib/features/auth/presentation/pages/welcome_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sot/core/config/app_colors.dart';
import 'package:sot/core/routes/app_routes.dart';
import 'package:sot/core/widgets/buttons.dart';
import 'package:sot/features/auth/state/auth_cubit.dart';
import 'package:sot/features/auth/state/auth_state.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spacingBelowLogo = screenWidth * 0.195; // Responsive ~78px
    final spacingBetweenText = screenWidth * 0.04; // Responsive ~16px
    final spacingAboveBelowCars = screenWidth * 0.12; // Responsive ~48px
    final carsSvgWidth = screenWidth; // Full width without cuts

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.pushNamed(context, AppRoutes.bookingHome);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final bool isLoading = state is AuthLoading;
          return Scaffold(
            backgroundColor: AppColors.white,
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 120,
                        width: 120,
                      ),
                    ),
                  ),

                  SizedBox(height: spacingBelowLogo),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColors.black,
                          fontSize: 36,
                        ),
                        children: const [
                          TextSpan(text: 'Welcome to '),
                          TextSpan(
                            text: 'Sunshine Onward',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: spacingBetweenText),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Your smooth ride between airport and city starts here',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(height: spacingAboveBelowCars),
                  SizedBox(
                    width: carsSvgWidth,
                    child: SvgPicture.asset(
                      'assets/images/cars.svg',
                      height: 30, // Adjusted height for visibility
                      width: carsSvgWidth,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  SizedBox(height: spacingAboveBelowCars),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CustomButton(
                      text: 'Sign in with Email',
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.signIn);
                      },
                      color: AppColors.primary,
                      height: 64.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                        : CustomButton(
                      text: 'Continue as Guest',
                      onPressed: () {
                        context.read<AuthCubit>().guestLogin();
                      },
                      color: AppColors.black,
                      height: 64.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.signUp);
                      },
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: AppColors.black,
                          ),
                          children: const [
                            TextSpan(text: 'Don\'t have an account? '),
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}