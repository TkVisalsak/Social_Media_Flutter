import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/models/hobby_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/follow_repository.dart';
import '../../../data/repositories/hobby_repository.dart';

class OnboardingController extends GetxController {
  OnboardingController({
    required this.authRepo,
    required this.hobbyRepo,
    required this.followRepo,
  });

  final AuthRepository authRepo;
  final HobbyRepository hobbyRepo;
  final FollowRepository followRepo;

  // ── Form state ────────────────────────────
  final dob = ''.obs;          // ISO yyyy-mm-dd
  final gender = ''.obs;       // male | female | custom

  final firstName = ''.obs;
  final lastName = ''.obs;
  final bio = ''.obs;
  final phoneNumber = ''.obs;
  final pickedImagePath = RxnString();

  // ── Hobbies & suggestions ─────────────────
  final allHobbies = <HobbyModel>[].obs;
  final selectedHobbies = <String>{}.obs;

  final suggestions = <HobbySuggestion>[].obs;
  final followedIds = <String>{}.obs;

  // ── UI state ──────────────────────────────
  final isLoading = false.obs;
  final isSuggestionsLoading = false.obs;
  final isSaving = false.obs;
  final error = ''.obs;

  void toggleHobby(String name) {
    if (selectedHobbies.contains(name)) {
      selectedHobbies.remove(name);
    } else {
      selectedHobbies.add(name);
    }
  }

  // ── Step actions ──────────────────────────
  Future<void> saveDob() async {
    if (dob.value.isEmpty) {
      error('Please pick your date of birth');
      return;
    }
    isSaving(true);
    final res = await authRepo.updatePersonalInfo(dob: dob.value);
    isSaving(false);
    if (res.success) {
      error('');
      Get.toNamed(AppRoutes.ONBOARDING_GENDER);
    } else {
      error(res.error ?? 'Failed to save');
    }
  }

  Future<void> saveGender() async {
    if (gender.value.isEmpty) {
      error('Please pick one');
      return;
    }
    isSaving(true);
    final res = await authRepo.updatePersonalInfo(gender: gender.value);
    isSaving(false);
    if (res.success) {
      error('');
      Get.toNamed(AppRoutes.ONBOARDING_PROFILE);
    } else {
      error(res.error ?? 'Failed to save');
    }
  }

  Future<void> saveProfile() async {
    if (firstName.value.trim().isEmpty || lastName.value.trim().isEmpty) {
      error('First and last name are required');
      return;
    }
    isSaving(true);
    final res = await authRepo.updatePersonalInfo(
      firstName: firstName.value.trim(),
      lastName: lastName.value.trim(),
      bio: bio.value.trim(),
      phoneNumber: phoneNumber.value.trim(),
    );
    if (res.success && pickedImagePath.value != null) {
      await authRepo.uploadProfilePic(pickedImagePath.value!);
    }
    isSaving(false);
    if (res.success) {
      error('');
      Get.toNamed(AppRoutes.ONBOARDING_HOBBY);
    } else {
      error(res.error ?? 'Failed to save');
    }
  }

  final hobbiesError = ''.obs;

  Future<void> loadHobbies() async {
    hobbiesError('');
    isLoading(true);
    final res = await hobbyRepo.getAll();
    isLoading(false);
    if (res.success) {
      allHobbies.assignAll(res.data ?? []);
    } else {
      hobbiesError(res.error ?? 'Failed to load interests');
    }
  }

  Future<void> saveHobbies() async {
    if (selectedHobbies.isEmpty) {
      error('Pick at least one interest');
      return;
    }
    isSaving(true);
    final res = await hobbyRepo.setMine(selectedHobbies.toList());
    isSaving(false);
    if (res.success) {
      error('');
      suggestions.clear();
      Get.toNamed(AppRoutes.ONBOARDING_FRIENDS);
      loadSuggestions();
    } else {
      error(res.error ?? 'Failed to save');
    }
  }

  Future<void> loadSuggestions() async {
    if (isSuggestionsLoading.value) return;
    isSuggestionsLoading(true);
    try {
      final res = await hobbyRepo.getSuggestions(min: 1);
      if (res.success) {
        suggestions.assignAll(res.data ?? []);
      } else {
        error(res.error ?? 'Failed to load suggestions');
      }
    } finally {
      isSuggestionsLoading(false);
    }
  }

  Future<void> followSuggestion(String userId) async {
    final res = await followRepo.follow(userId);
    if (res.success) {
      followedIds.add(userId);
    } else {
      Get.snackbar('Follow failed', res.error ?? 'Try again',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void dismissSuggestion(String userId) {
    suggestions.removeWhere((s) => s.user.id == userId);
  }

  void finishOnboarding() {
    Get.offAllNamed(AppRoutes.MAIN);
  }
}
