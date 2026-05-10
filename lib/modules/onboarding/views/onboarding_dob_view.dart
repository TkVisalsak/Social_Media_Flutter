import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_widgets.dart';

class OnboardingDobView extends GetView<OnboardingController> {
  const OnboardingDobView({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardScaffold(
      backLabel: 'Back to Sign Up',
      onBack: () => Get.offAllNamed(AppRoutes.LOGIN),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Text('🎉', style: TextStyle(fontSize: 54)),
          const SizedBox(height: 16),
          const OnboardTitle('Add your date of birth'),
          const OnboardSubtitle("So that we'll never forget your Birthday."),
          _DobPickerTile(controller: controller),
          const SizedBox(height: 24),
          Obx(() => OnboardErrorText(message: controller.error.value)),
          Obx(() => OnboardPrimaryButton(
                label: 'Next',
                isLoading: controller.isSaving.value,
                onPressed: controller.saveDob,
              )),
        ],
      ),
    );
  }
}

class _DobPickerTile extends StatelessWidget {
  const _DobPickerTile({required this.controller});
  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final value = controller.dob.value;
      return InkWell(
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime(now.year - 18, now.month, now.day),
            firstDate: DateTime(now.year - 100),
            lastDate: now,
          );
          if (picked != null) {
            final iso =
                '${picked.year.toString().padLeft(4, "0")}-${picked.month.toString().padLeft(2, "0")}-${picked.day.toString().padLeft(2, "0")}';
            controller.dob(iso);
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 18, color: Color(0xFF64748B)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value.isEmpty ? 'Select date of birth' : value,
                  style: TextStyle(
                    fontSize: 15,
                    color: value.isEmpty
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF0F172A),
                  ),
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
            ],
          ),
        ),
      );
    });
  }
}
