import "package:firebase_auth/firebase_auth.dart" as FirebaseAuth show User;
import "package:flutter/material.dart";

@immutable
class AuthUser{
  final bool isEmailVerified;
  const AuthUser({required this.isEmailVerified});

  factory AuthUser.fromFirebase(FirebaseAuth.User user)=> AuthUser(isEmailVerified: user.emailVerified);
}