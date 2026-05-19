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
          Obx(() => _PreferNotToSayPill(
                isActive: controller.gender.value == 'prefer_not_to_say',
                onTap: () => controller.gender('prefer_not_to_say'),
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

class _PreferNotToSayPill extends StatelessWidget {
  const _PreferNotToSayPill({required this.isActive, required this.onTap});
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF4F46E5).withValues(alpha: 0.12)
                    : const Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.do_not_disturb_alt_rounded,
                size: 22,
                color: isActive
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prefer not to say',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: isActive
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Your privacy is important to us',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF4F46E5), size: 22),
          ],
        ),
      ),
    );
  }
}
