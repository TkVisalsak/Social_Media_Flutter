abstract class ApiEndpoints {
  // Auth
  static const login    = '/auth/login';
  static const register = '/auth/register';
  static const refresh  = '/auth/refresh';
  static const logout   = '/auth/logout';

  // Feed
  static const feed      = '/feeds';

  // Likes
  static const likes     = '/likes';

  // Posts
  static const posts     = '/posts';
  static const comments  = '/comments';

  // Users
  static const users     = '/users';
  static const search    = '/users/search';
  static const follow    = '/users/follow';

  // Stories
  static const stories   = '/stories';

  // Reels
  static const reels     = '/reels';

  // Notifications
  static const notifications = '/notifications';

  // Direct
  static const conversations = '/direct/conversations';
  static const messages      = '/direct/messages';
}
