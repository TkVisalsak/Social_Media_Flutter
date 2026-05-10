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

  // Main
  static const FEED            = '/feed';
  static const SEARCH          = '/search';
  static const SHORTS          = '/shorts';
  static const SHOP            = '/shop';

  // Profile
  static const PROFILE         = '/profile';
  static const EDIT_PROFILE    = '/edit-profile';

  // Post
  static const POST_DETAIL     = '/post/:id';
  static const CREATE_POST     = '/create-post';

  // Story
  static const STORY           = '/story';

  // Direct
  static const DIRECT          = '/direct';
  static const CHAT            = '/direct/chat';

  // Notifications
  static const NOTIFICATIONS   = '/notifications';

  // Settings
  static const SETTINGS        = '/settings';
}