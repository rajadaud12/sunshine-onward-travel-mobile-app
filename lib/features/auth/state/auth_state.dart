import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  final String? email;

  const AuthState({this.email});

  @override
  List<Object?> get props => [email];
}

class AuthInitial extends AuthState {
  const AuthInitial() : super();
}

class AuthLoading extends AuthState {
  const AuthLoading({String? email}) : super(email: email);
}

class AuthSuccess extends AuthState {
  const AuthSuccess({String? email}) : super(email: email);
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message, String? email}) : super(email: email);

  @override
  List<Object?> get props => [message, email];
}