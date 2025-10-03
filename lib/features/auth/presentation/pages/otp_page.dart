// lib/features/auth/presentation/pages/otp_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sot/core/config/app_colors.dart';
import 'package:sot/core/routes/app_routes.dart';
import 'package:sot/core/widgets/buttons.dart';
import 'package:sot/features/auth/presentation/widgets/otp_widget.dart';
import 'package:sot/features/auth/state/auth_cubit.dart';
import 'package:sot/features/auth/state/auth_state.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String _otp = '';
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController()); // For clearing
  Timer? _timer;
  int _countdown = 20;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _countdown = 20;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  void _clearOtpFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _otp = '';
    setState(() {}); // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(  // Use global cubit
      listener: (context, state) {
        if (state is AuthOtpVerified) {
          Navigator.pushNamed(context, AppRoutes.createPassword);
          _clearOtpFields(); // Clear on success (optional)
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          _clearOtpFields(); // Unlock/clear on error
        } else if (state is AuthOtpSent) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP resent')));
          _startTimer(); // Restart timer on resend
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final bool isLoading = state is AuthLoading;
          final String displayEmail = state.email ?? 'your email';
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
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Please check your email',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'ve sent a code to $displayEmail',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  OtpWidget(
                    controllers: _controllers, // Pass for clearing
                    onComplete: (otp) {
                      _otp = otp;
                      if (!isLoading && _otp.length == 4) {
                        context.read<AuthCubit>().verifyOtp(_otp);
                      }
                    },
                  ),
                  const SizedBox(height: 48),
                  isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : CustomButton(
                    text: 'Verify',
                    onPressed: () {
                      if (_otp.length == 4) {
                        context.read<AuthCubit>().verifyOtp(_otp);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter full OTP')));
                      }
                    },
                    color: AppColors.primary,
                    height: 64.0,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: (_countdown == 0 && !isLoading && state.email != null) ? () {
                      context.read<AuthCubit>().sendOtp(state.email!, null);
                    } : null,
                    child: Text(
                      'Send code again ${(_countdown ~/ 60).toString().padLeft(2, '0')}:${(_countdown % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(color: AppColors.textSecondary),
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