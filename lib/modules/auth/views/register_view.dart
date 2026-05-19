import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_widgets.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('English',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                    Icon(Icons.keyboard_arrow_down,
                        color: Colors.grey, size: 16),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // Title
              const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4361EE),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign up to see photos and videos from your friends.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              // Avatar picker
              Center(
                child: GestureDetector(
                  onTap: controller.pickProfileImage,
                  child: Obx(() {
                    final path = controller.profilePicPath.value;
                    return Stack(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: path != null ? FileImage(File(path)) as ImageProvider : null,
                          child: path == null ? const Icon(Icons.person, size: 40, color: Colors.grey) : null,
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Color(0xFF4361EE), shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),
              // Username
              AuthTextField(
                label: 'Username',
                onChanged: controller.username.call,
              ),
              const SizedBox(height: 16),
              // Email
              AuthTextField(
                label: 'Email',
                onChanged: controller.email.call,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // Password
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
              const SizedBox(height: 16),
              // Confirm password
              Obx(() => AuthTextField(
                    label: 'Confirm Password',
                    onChanged: controller.confirmPassword.call,
                    obscureText: controller.obscureConfirm.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureConfirm.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: controller.toggleConfirmVisibility,
                    ),
                  )),
              const SizedBox(height: 16),
              // Terms checkbox
              Obx(() => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: controller.agreedToTerms.value,
                        onChanged: (_) => controller.toggleTerms(),
                        activeColor: const Color(0xFF4361EE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: RichText(
                            text: const TextSpan(
                              text: 'By creating an account, You agree to our ',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13),
                              children: [
                                TextSpan(
                                  text: 'Terms of use',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
              const SizedBox(height: 24),
              // Sign up button
              Obx(() => PrimaryButton(
                    label: 'Sign Up',
                    isLoading: controller.isLoading.value,
                    onTap: controller.register,
                  )),
              const SizedBox(height: 40),
              Center(
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: RichText(
                    text: const TextSpan(
                      text: 'Already have account? ',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Sign In',
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