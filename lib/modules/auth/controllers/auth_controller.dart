import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/middlewares/auth_middleware.dart';
import '../../../core/services/socket_service.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _repo;
  AuthController(this._repo);

  final _picker = ImagePicker();

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
  final profilePicPath  = RxnString();

  void togglePasswordVisibility() => obscurePassword(!obscurePassword.value);
  void toggleConfirmVisibility()  => obscureConfirm(!obscureConfirm.value);
  void toggleTerms()              => agreedToTerms(!agreedToTerms.value);

  Future<void> pickProfileImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) profilePicPath(picked.path);
  }

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
      AuthSession.setLoggedIn(true);
      Get.find<SocketService>().connect();
      final u = res.data;
      final needsOnboarding = u == null
          || (u.firstName?.trim().isEmpty ?? true)
          || (u.lastName?.trim().isEmpty ?? true);
      Get.offAllNamed(needsOnboarding ? AppRoutes.ONBOARDING_DOB : AppRoutes.MAIN);
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
    if (username.value.trim().isEmpty ||
        email.value.trim().isEmpty ||
        password.value.isEmpty) {
      Get.snackbar('Error', 'Username, email, and password are required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (password.value.length < 8) {
      Get.snackbar('Error', 'Password must be at least 8 characters',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (password.value != confirmPassword.value) {
      Get.snackbar('Error', 'Passwords do not match',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Backend requires a userName; if the UI didn't collect one, derive a
    // sensible default from the email's local part. The user can change it
    // later in the profile step.
    final cleanedEmail = email.value.trim();
    var resolvedUsername = username.value.trim();
    if (resolvedUsername.isEmpty) {
      final at = cleanedEmail.indexOf('@');
      resolvedUsername = at > 0 ? cleanedEmail.substring(0, at) : cleanedEmail;
    }

    isLoading(true);
    final res = await _repo.register(
      email: cleanedEmail,
      password: password.value,
      username: resolvedUsername,
    );
    isLoading(false);

    if (res.success) {
      AuthSession.setLoggedIn(true);
      Get.find<SocketService>().connect();
      if (profilePicPath.value != null) {
        await _repo.uploadProfilePic(profilePicPath.value!);
      }
      Get.offAllNamed(AppRoutes.ONBOARDING_DOB);
    } else {
      Get.snackbar('Registration failed', res.error ?? 'Something went wrong',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── Logout ────────────────────────────────────────
  Future<void> logout() async {
    await _repo.logout();
    AuthSession.setLoggedIn(false);
    Get.find<SocketService>().disconnect();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  // ── Google ────────────────────────────────────────
  Future<void> loginWithGoogle() async {
    Get.snackbar('Coming soon', 'Google sign-in not yet implemented',
        snackPosition: SnackPosition.BOTTOM);
  }
}