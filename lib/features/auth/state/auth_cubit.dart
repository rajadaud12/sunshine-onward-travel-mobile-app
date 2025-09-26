import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sot/features/auth/state/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  void setEmail(String email) {
    emit(AuthLoading(email: email));
    // Simulate some async work, replace with actual logic
    emit(AuthSuccess(email: email));
  }

  // Add other auth-related methods as needed
  void login() {
    emit(const AuthLoading());
    // Simulate login logic
    emit(const AuthSuccess());
  }

  void signUp() {
    emit(const AuthLoading());
    // Simulate sign-up logic
    emit(const AuthSuccess());
  }

  void verifyOtp() {
    emit(const AuthLoading());
    // Simulate OTP verification logic
    emit(const AuthSuccess());
  }
}