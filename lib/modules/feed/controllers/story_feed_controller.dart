import 'package:get/get.dart';

import '../../../data/models/story_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/local_storage.dart';
import '../../../data/repositories/story_repository.dart';

/// Loads the home stories bar (one row per user with active stories).
class StoryFeedController extends GetxController {
  StoryFeedController(this._repo);
  final StoryRepository _repo;

  final stories = <StoryModel>[].obs;
  final isLoading = false.obs;
  final error = RxnString();
  /// -1.0 = idle, 0.0–1.0 = upload in progress
  final uploadProgress = (-1.0).obs;

  String _myUserId = '';
  String get myUserId => _myUserId;

  final myProfilePic = ''.obs;
  final myUsername   = ''.obs;

  /// Group stories by user so the bar shows one avatar per user.
  List<List<StoryModel>> get groupedByUser {
    final byUser = <String, List<StoryModel>>{};
    for (final s in stories) {
      byUser.putIfAbsent(s.user.id, () => []).add(s);
    }
    return byUser.values.toList();
  }

  @override
  void onInit() {
    super.onInit();
    _loadMyUserId();
    fetch();
  }

  Future<void> _loadMyUserId() async {
    final me = await LocalStorage.user;
    _myUserId         = me?.id ?? '';
    myProfilePic.value = me?.profilePic ?? '';
    myUsername.value   = me?.username ?? me?.fullName ?? '';
  }

  Future<bool> createStory({
    required String filePath,
    String type       = 'image',
    String visibility = 'public',
  }) async {
    isLoading(true);
    uploadProgress.value = 0.0;
    final me  = await LocalStorage.user;
    final res = await _repo.create(
      filePath: filePath,
      type: type,
      visibility: visibility,
      onProgress: (p) => uploadProgress.value = p,
    );
    uploadProgress.value = -1.0;
    isLoading(false);

    if (res.success && res.data != null) {
      // Backend doesn't populate userId — inject current user.
      final story = res.data!;
      final withUser = StoryModel(
        id:         story.id,
        user:       me ?? const UserModel(id: '', email: ''),
        mediaUrl:   story.mediaUrl,
        type:       story.type,
        viewers:    story.viewers,
        visibility: story.visibility,
        expiresAt:  story.expiresAt,
        createdAt:  story.createdAt,
      );
      stories.insert(0, withUser);
      Get.snackbar('Story shared!', 'Your story is live for 24 h.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3));
      return true;
    }

    Get.snackbar('Upload failed', res.error ?? 'Try again',
        snackPosition: SnackPosition.BOTTOM);
    return false;
  }

  Future<void> fetch() async {
    if (isLoading.value) return;
    isLoading(true);
    error(null);
    final res = await _repo.getFeed();
    if (res.success && res.data != null) {
      stories.assignAll(res.data!);
    } else {
      error(res.error);
    }
    isLoading(false);
  }
}
