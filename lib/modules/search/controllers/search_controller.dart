import 'dart:async';

import 'package:get/get.dart';

import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';

class UserSearchController extends GetxController {
  final UserRepository _repo;
  UserSearchController(this._repo);

  final results = <UserModel>[].obs;
  final isLoading = false.obs;
  final error = RxnString();
  final query = ''.obs;

  Timer? _debounce;
  String _lastQuery = '';

  void onQueryChanged(String q) {
    _debounce?.cancel();
    final trimmed = q.trim();
    query(trimmed);

    if (trimmed.isEmpty) {
      results.clear();
      error(null);
      isLoading(false);
      _lastQuery = '';
      return;
    }

    if (trimmed == _lastQuery) return;

    _debounce = Timer(const Duration(milliseconds: 350), () => _search(trimmed));
  }

  Future<void> _search(String q) async {
    _lastQuery = q;
    isLoading(true);
    error(null);

    final res = await _repo.search(q);

    if (res.success) {
      results.assignAll(res.data!);
    } else {
      error(res.error);
      results.clear();
    }

    isLoading(false);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
