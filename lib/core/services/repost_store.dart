import 'package:get/get.dart';

import '../../data/providers/local_storage.dart';
import '../../data/repositories/repost_repository.dart';

/// Singleton that caches the current user's repost IDs so every PostCard and
/// ReelItem can check `isReposted` without a per-widget network call.
///
/// Register once in MainBinding. Call [reload] after login/logout.
class RepostStore extends GetxController {
  final RepostRepository _repo;
  RepostStore(this._repo);

  // contentId  →  repost document ID (needed to delete)
  final _map = <String, String>{};

  /// Bumped after every reload so widgets can react via [ever]/[Worker].
  final version = 0.obs;

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  Future<void> reload() async {
    final me = await LocalStorage.user;
    if (me == null) return;
    final res = await _repo.getUserReposts(me.id);
    if (res.success && res.data != null) {
      _map.clear();
      for (final r in res.data!) {
        _map[r.contentId] = r.id;
      }
    }
    version.value++;   // notify all listeners regardless of success
  }

  bool isReposted(String contentId) => _map.containsKey(contentId);
  String? repostDocId(String contentId) => _map[contentId];

  void add(String contentId, String repostDocId) =>
      _map[contentId] = repostDocId;

  void remove(String contentId) => _map.remove(contentId);
}
