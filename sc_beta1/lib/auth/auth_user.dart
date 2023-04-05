import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

@immutable
class AuthUser {
  final String? id;
  final String? email;
  final bool isEmailVerified;
  const AuthUser(
      {required this.id, required this.isEmailVerified, required this.email});

  factory AuthUser.fromFireBase(User user) => AuthUser(
      email: user.email, isEmailVerified: user.emailVerified, id: user.uid);
}
