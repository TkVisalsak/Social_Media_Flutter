import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/middlewares/auth_middleware.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _repo;
  AuthController(this._repo);

  // Form fields
  final email           = ''.obs;
  final password        = ''.obs;
  final confirmPassword = ''.obs;
  final username        = ''.obs;

  // UI state
  final isLoading       = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirm  = true.obs;
  final agreedToTerms   = true.obs;

  void togglePasswordVisibility() => obscurePassword(!obscurePassword.value);
  void toggleConfirmVisibility()  => obscureConfirm(!obscureConfirm.value);
  void toggleTerms()              => agreedToTerms(!agreedToTerms.value);

  // ── Login ────────────────────────────────────────
  Future<void> login() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isLoading(true);
    final res = await _repo.login(
      email: email.value.trim(),
      password: password.value,
    );
    isLoading(false);

    if (res.success) {
      AuthSession.setLoggedIn(true);   // update in-memory cache
      Get.offAllNamed(AppRoutes.FEED);
    } else {
      Get.snackbar('Login failed', res.error ?? 'Something went wrong',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── Register ─────────────────────────────────────
  Future<void> register() async {
    if (!agreedToTerms.value) {
      Get.snackbar('Error', 'Please agree to the terms',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (password.value != confirmPassword.value) {
      Get.snackbar('Error', 'Passwords do not match',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isLoading(true);
    final res = await _repo.register(
      email: email.value.trim(),
      password: password.value,
      username: username.value.trim(),
    );
    isLoading(false);

    if (res.success) {
      AuthSession.setLoggedIn(true);   // update in-memory cache
      Get.offAllNamed(AppRoutes.FEED);
    } else {
      Get.snackbar('Registration failed', res.error ?? 'Something went wrong',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── Logout ────────────────────────────────────────
  Future<void> logout() async {
    await _repo.logout();
    AuthSession.setLoggedIn(false);  // clear in-memory cache
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  // ── Google ────────────────────────────────────────
  Future<void> loginWithGoogle() async {
    Get.snackbar('Coming soon', 'Google sign-in not yet implemented',
        snackPosition: SnackPosition.BOTTOM);
  }
}