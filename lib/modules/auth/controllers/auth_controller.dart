import 'package:get/get.dart';
import '../../../data/providers/auth_provider.dart';

class AuthController extends GetxController {
  AuthController(this._authService);

  final AuthProvider _authService;

  // Reactive states
  var isLoading = false.obs;
  var isLoggedIn = false.obs;

  // LOGIN
  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Email and password required");
      return;
    }

    try {
      isLoading(true);

      await _authService.login(email: email, password: password);
      isLoggedIn(true);

      Get.snackbar("Success", "Login successful");

      Get.offAllNamed('/home');

    } catch (e) {
      Get.snackbar("Error", e.toString());

    } finally {
      isLoading(false);
    }
  }

  // REGISTER
  Future<void> register(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "All fields required");
      return;
    }

    try {
      isLoading(true);

      final username = email.split('@').first;
      await _authService.register(
        email: email,
        password: password,
        username: username,
      );

      Get.snackbar("Success", "Account created");
      Get.toNamed('/login');

    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  // LOGOUT
  void logout() {
    isLoggedIn(false);
    Get.offAllNamed('/login');
  }
}