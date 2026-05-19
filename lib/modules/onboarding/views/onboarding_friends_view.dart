import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/user_model.dart';
import '../../../data/repositories/hobby_repository.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_widgets.dart';

class OnboardingFriendsView extends GetView<OnboardingController> {
  const OnboardingFriendsView({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 8, bottom: 18),
              child: Text(
                'People Suggestions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ),
          Obx(() {
            if (controller.isSuggestionsLoading.value &&
                controller.suggestions.isEmpty) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ));
            }
            if (controller.suggestions.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'No suggestions yet — you can find people to follow later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ),
              );
            }
            return Column(
              children: controller.suggestions
                  .map((s) => _PersonRow(
                        suggestion: s,
                        controller: controller,
                      ))
                  .toList(),
            );
          }),
          const SizedBox(height: 12),
          Obx(() => OnboardErrorText(message: controller.error.value)),
          OnboardPrimaryButton(
            label: 'Continue',
            onPressed: controller.finishOnboarding,
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: controller.finishOnboarding,
            child: const Text(
              'Skip for now',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.suggestion, required this.controller});
  final HobbySuggestion suggestion;
  final OnboardingController controller;

  String _initials(UserModel u) {
    final f = ((u.firstName?.isNotEmpty ?? false)
        ? u.firstName!
        : (u.username ?? '?'))[0];
    final l = (u.lastName?.isNotEmpty ?? false) ? u.lastName![0] : '';
    return (f + l).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final u = suggestion.user;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: const Color(0xFFDBEAFE),
            backgroundImage: (u.profilePic != null && u.profilePic!.isNotEmpty)
                ? NetworkImage(u.profilePic!)
                : null,
            child: (u.profilePic == null || u.profilePic!.isEmpty)
                ? Text(
                    _initials(u),
                    style: const TextStyle(
                      color: Color(0xFF1E40AF),
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        u.username ?? u.fullName ?? u.email,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified,
                        size: 14, color: Color(0xFF2563EB)),
                  ],
                ),
                Text(
                  '${suggestion.matchCount} shared interests',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final followed = controller.followedIds.contains(u.id);
            return OutlinedButton(
              onPressed: followed ? null : () => controller.followSuggestion(u.id),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFF2563EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: Text(followed ? 'Following' : 'Follow'),
            );
          }),
          IconButton(
            onPressed: () => controller.dismissSuggestion(u.id),
            icon: const Icon(Icons.close, color: Color(0xFF64748B), size: 18),
          ),
        ],
      ),
    );
  }
}
