import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

@immutable // This and other class that inherit it cant be modified
class AuthUser{
  final bool isEmailVerified;
  const AuthUser(this.isEmailVerified);

  factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);
}