import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_widgets.dart';

class OnboardingHobbyView extends GetView<OnboardingController> {
  const OnboardingHobbyView({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger load on first build — controller persists, so this is safe.
    if (controller.allHobbies.isEmpty && !controller.isLoading.value) {
      controller.loadHobbies();
    }

    return OnboardScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 18),
            child: Text(
              'Select your interests',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
          ),
          Obx(() {
            if (controller.isLoading.value && controller.allHobbies.isEmpty) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ));
            }
            if (controller.hobbiesError.value.isNotEmpty &&
                controller.allHobbies.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Text(
                      controller.hobbiesError.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: controller.loadHobbies,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: controller.allHobbies.map((h) {
                final selected = controller.selectedHobbies.contains(h.name);
                return GestureDetector(
                  onTap: () => controller.toggleHobby(h.name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFEEF2FF)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF4F46E5)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (h.emoji != null && h.emoji!.isNotEmpty) ...[
                          Text(h.emoji!,
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          h.name,
                          style: TextStyle(
                            color: selected
                                ? const Color(0xFF4F46E5)
                                : const Color(0xFF0F172A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 18),
          Obx(() {
            final n = controller.selectedHobbies.length;
            final msg = n < 3
                ? '$n selected — pick at least 3 to get friend suggestions'
                : "$n selected — great, you'll get friend suggestions";
            return Text(
              msg,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
              ),
            );
          }),
          const SizedBox(height: 8),
          Obx(() => OnboardErrorText(message: controller.error.value)),
          Obx(() => OnboardPrimaryButton(
                label: 'Get started',
                isLoading: controller.isSaving.value,
                onPressed: controller.saveHobbies,
              )),
        ],
      ),
    );
  }
}
