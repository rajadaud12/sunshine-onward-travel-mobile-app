// lib/features/auth/presentation/pages/sign_up_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sot/core/config/app_colors.dart';
import 'package:sot/core/routes/app_routes.dart';
import 'package:sot/core/widgets/buttons.dart';
import 'package:sot/core/widgets/custom_text_field.dart';
import 'package:sot/core/widgets/google_button.dart';
import 'package:sot/features/auth/state/auth_cubit.dart';
import 'package:sot/features/auth/state/auth_state.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(  // Use global cubit
      listener: (context, state) {
        if (state is AuthOtpSent) {
          Navigator.pushNamed(context, AppRoutes.otp);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final bool isLoading = state is AuthLoading;
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_left, color: AppColors.white),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                            children: const [
                              TextSpan(text: 'Sign '),
                              TextSpan(
                                text: 'Up',
                                style: TextStyle(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'A quick sign-up is all you need to get moving.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/images/sign_up_cars.svg',
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.fitWidth,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 32),
                          CustomTextField(
                            label: 'Full Name',
                            hintText: 'Enter your Full Name',
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Email',
                            hintText: 'Enter your Email',
                            controller: _emailController,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 32),
                          isLoading
                              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                              : CustomButton(
                            text: 'Get OTP',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthCubit>().sendOtp(_emailController.text, _nameController.text);
                              }
                            },
                            color: AppColors.primary,
                            height: 64.0,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: AppColors.border,
                                  height: 1,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  'Or',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: AppColors.border,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          isLoading
                              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                              : GoogleButton(
                            onPressed: () {
                              context.read<AuthCubit>().googleLogin();
                            },
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.signIn);
                              },
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: AppColors.black),
                                  children: const [
                                    TextSpan(text: 'Already have an account? '),
                                    TextSpan(
                                      text: 'Sign In',
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