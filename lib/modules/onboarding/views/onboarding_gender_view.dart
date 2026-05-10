import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_widgets.dart';

class OnboardingGenderView extends GetView<OnboardingController> {
  const OnboardingGenderView({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardScaffold(
      backLabel: 'Go back',
      onBack: Get.back,
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Text('⚥', style: TextStyle(fontSize: 54)),
          const SizedBox(height: 16),
          const OnboardTitle("What's your Gender?"),
          const OnboardSubtitle('Select which gender do you identify as'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GenderCircle(
                glyph: '♂',
                label: 'Male',
                color: const Color(0xFF2563EB),
                value: 'male',
                controller: controller,
              ),
              const SizedBox(width: 14),
              const Text('or', style: TextStyle(color: Color(0xFF64748B))),
              const SizedBox(width: 14),
              _GenderCircle(
                glyph: '♀',
                label: 'Female',
                color: const Color(0xFFEC4899),
                value: 'female',
                controller: controller,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() => _CustomPill(
                isActive: controller.gender.value == 'custom',
                onTap: () => controller.gender('custom'),
              )),
          const SizedBox(height: 12),
          Obx(() => OnboardErrorText(message: controller.error.value)),
          Obx(() => OnboardPrimaryButton(
                label: 'Next',
                isLoading: controller.isSaving.value,
                onPressed: controller.saveGender,
              )),
        ],
      ),
    );
  }
}

class _GenderCircle extends StatelessWidget {
  const _GenderCircle({
    required this.glyph,
    required this.label,
    required this.color,
    required this.value,
    required this.controller,
  });

  final String glyph;
  final String label;
  final Color color;
  final String value;
  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.gender.value == value;
      return GestureDetector(
        onTap: () => controller.gender(value),
        child: Column(
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: active ? color : const Color(0xFFE2E8F0),
                  width: 2,
                ),
                color: Colors.white,
              ),
              alignment: Alignment.center,
              child: Text(
                glyph,
                style: TextStyle(fontSize: 36, color: color),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: active ? color : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _CustomPill extends StatelessWidget {
  const _CustomPill({required this.isActive, required this.onTap});
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isActive ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Custom',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
