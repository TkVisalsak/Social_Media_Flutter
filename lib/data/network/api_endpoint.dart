abstract class ApiEndpoints {
  // ── Auth ──────────────────────────────────────
  static const login = '/auth/login';
  static const signup = '/auth/signup';
  static const register = '/auth/signup'; // alias
  static const refresh = '/auth/refresh';
  static const logout = '/auth/logout';
  static const me = '/auth/me';
  static const personalInfo = '/auth/personal_info';
  static const updateProfile = '/auth/update-profile';
  static const userById = '/auth/user'; // /auth/user/:id
  static const oauthGoogle = '/auth/google';
  static const oauthPersonalInfo = '/auth/oAuthPersonal_info';

  // ── Feeds ─────────────────────────────────────
  static const feed = '/feeds';
  static const feeds = '/feeds';

  // ── Feed likes & comments ─────────────────────
  static const likes = '/likes';
  static const comments = '/comments';

  // ── Follow ────────────────────────────────────
  static const follow = '/follow';
  static const unfollow = '/follow/unfollow';
  static const followers = '/follow/followers';
  static const following = '/follow/following';
  static const followCheck = '/follow/check';
  static const followNotFollowingBack = '/follow/not-following-back';

  // ── Save ──────────────────────────────────────
  static const save = '/save';
  static const saveCheck = '/save/check';

  // ── Repost ────────────────────────────────────
  static const repost = '/repost';
  static const repostFeed = '/repost/feed';
  static const repostShort = '/repost/short';
  static const repostUser = '/repost/user';

  // ── Shorts ────────────────────────────────────
  static const shortsCreate = '/shorts/video/createshort';
  static const shortsAll = '/shorts/video/getallshorts';
  static const shortsView = '/shorts/video/short'; // /:id/viewshort
  static const shortLikes = '/shorts/likes';
  static const shortComments = '/shorts/comments';

  // ── Stories ───────────────────────────────────
  static const stories = '/story';
  static const storyFeed = '/story/feed';
  static const storyMine = '/story/me';
  static const storyView = '/story/view';

  // ── Messaging ─────────────────────────────────
  static const messages = '/messages';
  static const conversations = '/conversations';
  static const conversationDm = '/conversations/dm';
  static const conversationGroup = '/conversations/group';

  // ── Posts (legacy) ────────────────────────────
  static const posts = '/posts';

  // ── Users (legacy aliases) ────────────────────
  static const users = '/auth/user';
  static const search = '/users/search';
  static const feedsByUser  = '/feeds/user';        // + /:userId
  static const shortsByUser = '/shorts/video/user'; // + /:userId

  // ── Notifications ─────────────────────────────
  static const notifications = '/notifications';

  // ── Hobbies / friend suggestions ──────────────
  static const hobbies = '/hobbies';
  static const myHobbies = '/hobbies/me';
  static const hobbySuggestions = '/hobbies/suggestions';
}
