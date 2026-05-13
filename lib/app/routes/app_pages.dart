import 'package:get/get.dart';

import '../../core/middlewares/auth_middleware.dart';
import '../../core/services/socket_service.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/register_view.dart';
import '../../modules/main/bindings/main_binding.dart';
import '../../modules/main/views/main_navigation_screen.dart';
import '../../data/repositories/message_repository.dart';
import '../../modules/message/controllers/chat_view_controller.dart';
import '../../modules/message/screens/chat_view.dart';
import '../../modules/onboarding/bindings/onboarding_binding.dart';
import '../../modules/onboarding/views/onboarding_dob_view.dart';
import '../../modules/onboarding/views/onboarding_friends_view.dart';
import '../../modules/onboarding/views/onboarding_gender_view.dart';
import '../../modules/onboarding/views/onboarding_hobby_view.dart';
import '../../modules/onboarding/views/onboarding_profile_view.dart';
import '../../modules/post_detail/bindings/post_detail_binding.dart';
import '../../modules/post_detail/views/post_detail_view.dart';
import '../../modules/profile/bindings/other_profile_binding.dart';
import '../../modules/profile/bindings/profile_binding.dart';
import '../../modules/profile/views/edit_profile_view.dart';
import '../../modules/profile/views/other_profile_view.dart';
import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/splash/views/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    // ── Splash ───────────────────────────────────────
    GetPage(
      name:    AppRoutes.SPLASH,
      page:    () => const SplashView(),
      binding: SplashBinding(),
    ),

    // ── Auth ─────────────────────────────────────────
    GetPage(
      name:    AppRoutes.LOGIN,
      page:    () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name:    AppRoutes.REGISTER,
      page:    () => const RegisterView(),
      binding: AuthBinding(),
    ),

    // ── Onboarding ────────────────────────────────────
    GetPage(
      name:        AppRoutes.ONBOARDING_DOB,
      page:        () => const OnboardingDobView(),
      binding:     OnboardingBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name:        AppRoutes.ONBOARDING_GENDER,
      page:        () => const OnboardingGenderView(),
      binding:     OnboardingBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name:        AppRoutes.ONBOARDING_PROFILE,
      page:        () => const OnboardingProfileView(),
      binding:     OnboardingBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name:        AppRoutes.ONBOARDING_HOBBY,
      page:        () => const OnboardingHobbyView(),
      binding:     OnboardingBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name:        AppRoutes.ONBOARDING_FRIENDS,
      page:        () => const OnboardingFriendsView(),
      binding:     OnboardingBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // ── Main Shell (all tabs) ─────────────────────────
    GetPage(
      name:        AppRoutes.MAIN,
      page:        () => const MainNavigationScreen(),
      binding:     MainBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // ── Post Detail ───────────────────────────────────
    GetPage(
      name:        AppRoutes.POST_DETAIL,
      page:        () => const PostDetailView(),
      binding:     PostDetailBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // ── Other Profile ─────────────────────────────────
    GetPage(
      name:        AppRoutes.OTHER_PROFILE,
      page:        () => const OtherProfileView(),
      binding:     OtherProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // ── Edit Profile ──────────────────────────────────
    GetPage(
      name:        AppRoutes.EDIT_PROFILE,
      page:        () => const EditProfileView(),
      binding:     ProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // ── Individual Chat View ──────────────────────────
    GetPage(
      name:        AppRoutes.CHAT,
      page:        () => const ChatView(),
      binding:     BindingsBuilder(() {
        Get.lazyPut<ChatViewController>(
          () => ChatViewController(
            Get.find<MessageRepository>(),
            Get.find<SocketService>(),
          ),
        );
      }),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
