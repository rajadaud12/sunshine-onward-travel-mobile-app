// lib/features/auth/state/auth_cubit.dart
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sot/core/utils/api_service.dart';
import 'package:sot/features/auth/state/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  Future<void> sendOtp(String email, String? name) async {
    emit(const AuthLoading());
    try {
      print('AuthCubit.sendOtp -> sending: email=$email name=$name');
      final Map<String, dynamic> payload = {'email': email};
      if (name != null && name.isNotEmpty) {
        payload['name'] = name;
      }
      final response = await ApiService.post('/auth/send-otp', payload);
      print('AuthCubit.sendOtp -> status: ${response.statusCode} body: ${response.body}');
      if (response.statusCode == 200) {
        emit(AuthOtpSent(email: email));
      } else {
        emit(AuthError(message: response.body, email: email));
      }
    } catch (e) {
      print('AuthCubit.sendOtp -> exception: $e');
      emit(AuthError(message: e.toString(), email: email));
    }
  }

  Future<void> verifyOtp(String otp) async {
    final currentState = state;
    final String? email = currentState.email;
    print('AuthCubit.verifyOtp -> state.email: $email otp: $otp');
    if (email == null) return emit(const AuthError(message: 'No email set'));
    emit(const AuthLoading());
    try {
      final Map<String, dynamic> payload = {'email': email, 'otp': otp};
      print('AuthCubit.verifyOtp -> payload: $payload');
      final response = await ApiService.post('/auth/verify-otp', payload);
      print('AuthCubit.verifyOtp -> status: ${response.statusCode} body: ${response.body}');
      if (response.statusCode == 200) {
        emit(AuthOtpVerified(email: email));
      } else {
        emit(AuthError(message: response.body, email: email));
      }
    } catch (e) {
      print('AuthCubit.verifyOtp -> exception: $e');
      emit(AuthError(message: e.toString(), email: email));
    }
  }

  Future<void> createAccount(String password, {String? email}) async {
    // Prefer explicit email param; fallback to cubit state
    final String? targetEmail = email ?? state.email;
    print('AuthCubit.createAccount -> invoked. targetEmail: $targetEmail');

    if (targetEmail == null || targetEmail.trim().isEmpty) {
      print('AuthCubit.createAccount -> ERROR: no email available');
      return emit(const AuthError(message: 'No email set'));
    }

    // Validate password a bit too
    if (password.trim().length < 6) {
      print('AuthCubit.createAccount -> ERROR: weak password');
      return emit(AuthError(message: 'Password must be at least 6 characters', email: targetEmail));
    }

    emit(const AuthLoading());
    try {
      final Map<String, dynamic> payload = {'email': targetEmail, 'password': password};
      print('AuthCubit.createAccount -> payload: $payload');
      final response = await ApiService.post('/auth/create-user', payload);
      print('AuthCubit.createAccount -> resp: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        // Try sign in locally after backend creates user
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: targetEmail, password: password);
        emit(AuthSuccess(email: targetEmail));
      } else {
        emit(AuthError(message: response.body, email: targetEmail));
      }
    } catch (e) {
      print('AuthCubit.createAccount -> exception: $e');
      emit(AuthError(message: e.toString(), email: targetEmail));
    }
  }

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      emit(const AuthSuccess());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: e.message ?? 'Login failed'));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> googleLogin() async {
    emit(const AuthLoading());
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: <String>['email']);

      // Force account choice to ensure fresh login if needed
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        emit(const AuthError(message: 'Google sign-in cancelled'));
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      // 1. Sign in to Firebase Authentication
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // 2. Sync with Backend to create/update User Document
        try {
          await ApiService.post('/auth/google-login-sync', {
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName,
            'photoURL': user.photoURL,
          });
          print('Google user synced with backend successfully');
        } catch (apiError) {
          // Log error but allow login to proceed if auth succeeded
          print('Backend sync failed: $apiError');
        }

        emit(const AuthSuccess());
      } else {
        emit(const AuthError(message: 'Google Sign-In failed: User is null'));
      }

    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: e.message ?? 'Google login failed'));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    emit(const AuthLoading());
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      emit(const AuthSuccess());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: e.message ?? 'Reset failed'));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> guestLogin() async {
    emit(const AuthLoading());
    try {
      final response = await ApiService.post('/auth/guest-login', {});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String token = data['token'];
        await FirebaseAuth.instance.signInWithCustomToken(token);
        emit(const AuthSuccess());
      } else {
        emit(AuthError(message: response.body));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}