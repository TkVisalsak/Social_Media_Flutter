import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/follow_repository.dart';
import '../../../data/repositories/hobby_repository.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(
      () => OnboardingController(
        authRepo: Get.find<AuthRepository>(),
        hobbyRepo: Get.find<HobbyRepository>(),
        followRepo: Get.find<FollowRepository>(),
      ),
      fenix: true,
    );
  }
}
