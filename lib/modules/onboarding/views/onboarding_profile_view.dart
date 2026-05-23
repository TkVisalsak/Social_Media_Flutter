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
