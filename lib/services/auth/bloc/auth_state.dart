import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:notesapp/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({
    required this.isLoading,
    this.loadingText = 'Please wait..',
  });
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required isLoading})
      : super(isLoading: isLoading);
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering({required this.exception, required isLoading})
      : super(isLoading: isLoading);
}

class AuthStateLogin extends AuthState {
  final AuthUser user;
  const AuthStateLogin({required this.user, required isLoading})
      : super(isLoading: isLoading);
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({required isLoading})
      : super(isLoading: isLoading);
}

class AuthStateLogout extends AuthState with EquatableMixin {
  final Exception? exception;
  const AuthStateLogout({
    required this.exception,
    required isLoading,
    String? loadingText,
  }) : super(
          isLoading: isLoading,
          loadingText: loadingText,
        );

  @override
  List<Object?> get props => [exception, isLoading];
}
