import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_widgets.dart';

class OnboardingProfileView extends GetView<OnboardingController> {
  const OnboardingProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardScaffold(
      backLabel: 'Go back',
      onBack: Get.back,
      child: Column(
        children: [
          const SizedBox(height: 8),
          const OnboardTitle("Let's create your profile"),
          const SizedBox(height: 24),
          _AvatarPicker(controller: controller),
          const SizedBox(height: 20),
          _Field(label: 'First name', onChanged: controller.firstName.call),
          const SizedBox(height: 12),
          _Field(label: 'Last name', onChanged: controller.lastName.call),
          const SizedBox(height: 12),
          _Field(label: 'Bio', onChanged: controller.bio.call, maxLines: 2),
          const SizedBox(height: 12),
          _Field(
            label: 'Phone number',
            onChanged: controller.phoneNumber.call,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          Obx(() => OnboardErrorText(message: controller.error.value)),
          Obx(() => OnboardPrimaryButton(
                label: 'Next',
                isLoading: controller.isSaving.value,
                onPressed: controller.saveProfile,
              )),
        ],
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({required this.controller});
  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          final path = controller.pickedImagePath.value;
          return Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: const Color(0xFFDBEAFE),
                backgroundImage: path != null ? FileImage(File(path)) : null,
                child: path == null
                    ? const Icon(Icons.person,
                        size: 54, color: Color(0xFF1E40AF))
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.add, size: 18, color: Colors.white),
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            // Hook up image_picker when the dependency is added.
            // controller.pickedImagePath(<picked path>);
            Get.snackbar(
              'Photo upload',
              'Add image_picker dependency to enable',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
          child: const Text(
            'Add profile photo',
            style: TextStyle(
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF64748B)),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
      ),
    );
  }
}
