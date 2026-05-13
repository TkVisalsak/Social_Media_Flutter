abstract class AppRoutes {
  // Auth
  static const SPLASH          = '/splash';
  static const LOGIN           = '/login';
  static const REGISTER        = '/register';
  static const FORGOT_PASSWORD = '/forgot-password';
  static const RESET_PASSWORD  = '/reset-password';

  // Onboarding
  static const ONBOARDING_DOB     = '/onboarding/dob';
  static const ONBOARDING_GENDER  = '/onboarding/gender';
  static const ONBOARDING_PROFILE = '/onboarding/profile';
  static const ONBOARDING_HOBBY   = '/onboarding/hobby';
  static const ONBOARDING_FRIENDS = '/onboarding/friends';

  // Main shell (replaces the old per-tab routes)
  static const MAIN  = '/main';
  static const FEED  = '/main'; // kept as alias for auth middleware redirects

  // Post
  static const POST_DETAIL  = '/post/:id';
  static const CREATE_POST  = '/create-post';

  // Profile
  static const PROFILE      = '/profile';
  static const EDIT_PROFILE = '/edit-profile';
  static const OTHER_PROFILE = '/other-profile';

  // Story
  static const STORY        = '/story';
  static const STORY_VIEWER = '/story-viewer';

  // Direct / Chat
  static const DIRECT       = '/direct';
  static const CHAT         = '/direct/chat';

  // Search & Shorts (accessed through MainNavigationScreen tabs)
  static const SEARCH  = '/search';
  static const SHORTS  = '/shorts';

  // Notifications / Settings
  static const NOTIFICATIONS = '/notifications';
  static const SETTINGS      = '/settings';
}
