import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/middlewares/auth_middleware.dart';
import '../../../data/providers/local_storage.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 2));

    try {
      final token = await LocalStorage.token;

      debugPrint('SplashController — token: $token');

      final isLoggedIn = token != null && token.trim().isNotEmpty;

      // Sync the in-memory session flag
      AuthSession.setLoggedIn(isLoggedIn);

      if (isLoggedIn) {
        Get.offAllNamed(AppRoutes.MAIN);
      } else {
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    } catch (e) {
      // If secure storage fails for any reason, go to login
      debugPrint('SplashController — error reading token: $e');
      AuthSession.setLoggedIn(false);
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}