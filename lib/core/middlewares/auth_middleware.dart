import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../data/providers/local_storage.dart';

/// NOTE: flutter_secure_storage is async so we cannot read the token
/// directly here. Instead the splash controller handles the initial
/// auth check. This middleware uses a lightweight in-memory cache
/// that is populated after the splash resolves.
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // AuthService caches the token in memory after splash reads it
    final isLoggedIn = AuthSession.isLoggedIn;
    return isLoggedIn
        ? null
        : const RouteSettings(name: AppRoutes.LOGIN);
  }
}

/// Simple in-memory session flag — set once after splash reads
/// the token from secure storage. Avoids calling async code
/// inside the synchronous redirect() method.
class AuthSession {
  AuthSession._();

  static bool _loggedIn = false;

  static bool get isLoggedIn => _loggedIn;

  static void setLoggedIn(bool value) => _loggedIn = value;
}