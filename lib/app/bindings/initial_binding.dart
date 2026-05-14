import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../core/services/socket_service.dart';
import '../../data/network/dio_client.dart';

// Providers
import '../../data/providers/auth_provider.dart';
import '../../data/providers/highlight_provider.dart';
import '../../data/providers/comments_provider.dart';
import '../../data/providers/feed_provider.dart';
import '../../data/providers/follow_provider.dart';
import '../../data/providers/hobby_provider.dart';
import '../../data/providers/message_provider.dart';
import '../../data/providers/notification_provider.dart';
import '../../data/providers/repost_provider.dart';
import '../../data/providers/save_provider.dart';
import '../../data/providers/short_provider.dart';
import '../../data/providers/story_provider.dart';
import '../../data/providers/user_provider.dart';

// Repositories
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/highlight_repository.dart';
import '../../data/repositories/comments_repository.dart';
import '../../data/repositories/feed_repository.dart';
import '../../data/repositories/follow_repository.dart';
import '../../data/repositories/hobby_repository.dart';
import '../../data/repositories/message_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/repost_repository.dart';
import '../../data/repositories/save_repository.dart';
import '../../data/repositories/short_repository.dart';
import '../../data/repositories/story_repository.dart';
import '../../data/repositories/user_repository.dart';

/// Registers app-wide singletons (Dio, Socket, every Provider/Repository).
///
/// Module-specific bindings only need to register their controllers — they
/// can `Get.find()` any repository they depend on.
class InitialBinding implements Bindings {
  @override
  void dependencies() {
    // ── Core singletons ──────────────────────────────────
    Get.put<Dio>(DioClient.instance, permanent: true);
    Get.put<SocketService>(SocketService(), permanent: true);

    // ── Providers (lazy + fenix so they survive route changes) ──
    Get.lazyPut<AuthProvider>(
        () => AuthProvider(Get.find<Dio>()), fenix: true);
    Get.lazyPut<CommentsProvider>(
        () => CommentsProvider(Get.find<Dio>()), fenix: true);
    Get.lazyPut<FeedProvider>(
        () => FeedProvider(Get.find<Dio>()), fenix: true);
    Get.lazyPut<FollowProvider>(
        () => FollowProvider(Get.find<Dio>()), fenix: true);
    Get.lazyPut<HobbyProvider>(
        () => HobbyProvider(Get.find<Dio>()), fenix: true);
    Get.lazyPut<MessageProvider>(
        () => MessageProvider(Get.find<Dio>()), fenix: true);
    Get.lazyPut<NotificationProvider>(
        () => NotificationProvider(Get.find<Dio>()), fenix: true);
    Get.lazyPut<RepostProvider>(
        () => RepostProvider(Get.find<Dio>()), fenix: true);
    Get.lazyPut<SaveProvider>(
        () => SaveProvider(Get.find<Dio>()), fenix: true);
    Get.lazyPut<ShortProvider>(
        () => ShortProvider(Get.find<Dio>()), fenix: true);
    Get.lazyPut<StoryProvider>(
        () => StoryProvider(Get.find<Dio>()), fenix: true);
    Get.lazyPut<UserProvider>(
        () => UserProvider(Get.find<Dio>()), fenix: true);
    Get.lazyPut<HighlightProvider>(
        () => HighlightProvider(Get.find<Dio>()), fenix: true);

    // ── Repositories ─────────────────────────────────────
    Get.lazyPut<AuthRepository>(
        () => AuthRepositoryImpl(Get.find<AuthProvider>()), fenix: true);
    Get.lazyPut<CommentsRepository>(
        () => CommentsRepositoryImpl(Get.find<CommentsProvider>()),
        fenix: true);
    Get.lazyPut<FeedRepository>(
        () => FeedRepositoryImpl(Get.find<FeedProvider>()), fenix: true);
    Get.lazyPut<FollowRepository>(
        () => FollowRepositoryImpl(Get.find<FollowProvider>()), fenix: true);
    Get.lazyPut<HobbyRepository>(
        () => HobbyRepositoryImpl(Get.find<HobbyProvider>()), fenix: true);
    Get.lazyPut<MessageRepository>(
        () => MessageRepositoryImpl(Get.find<MessageProvider>()), fenix: true);
    Get.lazyPut<NotificationRepository>(
        () => NotificationRepositoryImpl(Get.find<NotificationProvider>()),
        fenix: true);
    Get.lazyPut<RepostRepository>(
        () => RepostRepositoryImpl(Get.find<RepostProvider>()), fenix: true);
    Get.lazyPut<SaveRepository>(
        () => SaveRepositoryImpl(Get.find<SaveProvider>()), fenix: true);
    Get.lazyPut<ShortRepository>(
        () => ShortRepositoryImpl(Get.find<ShortProvider>()), fenix: true);
    Get.lazyPut<StoryRepository>(
        () => StoryRepositoryImpl(Get.find<StoryProvider>()), fenix: true);
    Get.lazyPut<UserRepository>(
        () => UserRepositoryImpl(Get.find<UserProvider>()), fenix: true);
    Get.lazyPut<HighlightRepository>(
        () => HighlightRepositoryImpl(Get.find<HighlightProvider>()), fenix: true);
  }
}
