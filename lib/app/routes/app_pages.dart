import 'package:get/get.dart';

import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/splash/views/splash_view.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/register_view.dart';
import '../../modules/feed/bindings/feed_binding.dart';
import '../../modules/feed/views/feed_view.dart';
import '../../modules/onboarding/bindings/onboarding_binding.dart';
import '../../modules/onboarding/views/onboarding_dob_view.dart';
import '../../modules/onboarding/views/onboarding_gender_view.dart';
import '../../modules/onboarding/views/onboarding_profile_view.dart';
import '../../modules/onboarding/views/onboarding_hobby_view.dart';
import '../../modules/onboarding/views/onboarding_friends_view.dart';
import '../../modules/post_detail/bindings/post_detail_binding.dart';
import '../../modules/post_detail/views/post_detail_view.dart';
import '../../modules/profile/bindings/profile_binding.dart';
import '../../modules/profile/views/profile_view.dart';
// import '../../modules/story/bindings/story_binding.dart';
// import '../../modules/story/views/story_view.dart';
// import '../../modules/search/bindings/search_binding.dart';
// import '../../modules/search/views/search_view.dart';
// import '../../modules/notifications/bindings/notifications_binding.dart';
// import '../../modules/notifications/views/notifications_view.dart';
import '../../modules/message/bindings/message_binding.dart';
import '../../modules/message/views/message_view.dart';
import '../../modules/shorts/bindings/shorts_binding.dart';
import '../../modules/shorts/views/shorts_view.dart';
// import '../../modules/settings/bindings/settings_binding.dart';
// import '../../modules/settings/views/settings_view.dart';
import '../../core/middlewares/auth_middleware.dart';
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

    // ── Main / Feed ───────────────────────────────────
    GetPage(
      name:        AppRoutes.FEED,
      page:        () => const FeedView(),
      binding:     FeedBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // ── Post Detail / Comments ────────────────────────
    GetPage(
      name:        AppRoutes.POST_DETAIL,
      page:        () => const PostDetailView(),
      binding:     PostDetailBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // ── Search ────────────────────────────────────────
    // GetPage(
    //   name:        AppRoutes.SEARCH,
    //   page:        () => const SearchView(),
    //   binding:     SearchBinding(),
    //   middlewares: [AuthMiddleware()],
    // ),

    // ── Shorts ────────────────────────────────────────
    GetPage(
      name:        AppRoutes.SHORTS,
      page:        () => const ShortsView(),
      binding:     ShortsBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // ── Profile ───────────────────────────────────────
    GetPage(
      name:        AppRoutes.PROFILE,
      page:        () => const ProfileView(),
      binding:     ProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // ── Story ─────────────────────────────────────────
    // GetPage(
    //   name:        AppRoutes.STORY,
    //   page:        () => const StoryView(),
    //   binding:     StoryBinding(),
    //   middlewares: [AuthMiddleware()],
    // ),

    // ── Direct Messages ───────────────────────────────
    GetPage(
      name:        AppRoutes.DIRECT,
      page:        () => const DirectView(),
      binding:     DirectBinding(),
      middlewares: [AuthMiddleware()],
    ),
    // GetPage(
    //   name:        AppRoutes.CHAT,
    //   page:        () => const ChatView(),
    //   binding:     DirectBinding(),
    //   middlewares: [AuthMiddleware()],
    // ),

    // ── Notifications ─────────────────────────────────
    // GetPage(
    //   name:        AppRoutes.NOTIFICATIONS,
    //   page:        () => const NotificationsView(),
    //   binding:     NotificationsBinding(),
    //   middlewares: [AuthMiddleware()],
    // ),

    // ── Settings ──────────────────────────────────────
    // GetPage(
    //   name:        AppRoutes.SETTINGS,
    //   page:        () => const SettingsView(),
    //   binding:     SettingsBinding(),
    //   middlewares: [AuthMiddleware()],
    // ),
  ];
}