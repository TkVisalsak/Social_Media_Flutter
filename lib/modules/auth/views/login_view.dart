import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../widgets/auth_widgets.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Language selector
              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('English',
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Icon(Icons.keyboard_arrow_down,
                          color: Colors.grey, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Title
              const Text(
                'Sign in',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4361EE),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please login to continue to your account.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              // Email field
              AuthTextField(
                label: 'Email',
                onChanged: controller.email.call,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // Password field
              Obx(() => AuthTextField(
                    label: 'Password',
                    onChanged: controller.password.call,
                    obscureText: controller.obscurePassword.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscurePassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  )),
              const SizedBox(height: 8),
              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.FORGOT_PASSWORD),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: Color(0xFF4361EE),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Sign in button
              Obx(() => PrimaryButton(
                    label: 'Sign in',
                    isLoading: controller.isLoading.value,
                    onTap: controller.login,
                  )),
              const SizedBox(height: 20),
              // Divider
              const OrDivider(),
              const SizedBox(height: 20),
              // Google button
              GoogleButton(
                label: 'Sign in with Google',
                onTap: controller.loginWithGoogle,
              ),
              const SizedBox(height: 40),
              // Sign up link
              Center(
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.REGISTER),
                  child: RichText(
                    text: const TextSpan(
                      text: 'Need an account? ',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                            color: Color(0xFF4361EE),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}