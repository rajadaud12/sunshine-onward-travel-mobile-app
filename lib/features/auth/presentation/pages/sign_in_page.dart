// lib/features/auth/presentation/pages/sign_in_page.dart
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

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
      child: BlocListener<AuthCubit, AuthState>(
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
                                  text: 'In',
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Welcome back! Let\'s get you moving',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                    SvgPicture.asset(
                      'assets/images/sign_in_cars.svg',
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
                            const SizedBox(height: 8),
                            CustomTextField(
                              label: 'Email',
                              hintText: 'Enter your Email',
                              controller: _emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: 'Password',
                              hintText: 'Enter your Password',
                              obscureText: _obscurePassword,
                              controller: _passwordController,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: AppColors.placeholder,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRoutes.forgotPassword);
                                },
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            isLoading
                                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                                : CustomButton(
                              text: 'Login',
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthCubit>().login(_emailController.text, _passwordController.text);
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
                                  Navigator.pushNamed(context, AppRoutes.signUp);
                                },
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(color: AppColors.black),
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
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}