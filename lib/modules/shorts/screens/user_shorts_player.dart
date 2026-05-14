import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/models/short_model.dart';
import '../../../data/repositories/short_repository.dart';
import '../controllers/shorts_controller.dart';
import '../widgets/reel_item.dart';

/// Fullscreen shorts player for a specific user's shorts.
///
/// Pushes a local list of [ShortModel]s into a [ShortsController] so that
/// [ReelItem] (which calls `Get.find<ShortsController>()`) works correctly.
///
/// Strategy:
/// - If the global [ShortsController] is already registered, temporarily
///   replace its `shorts` list with [shorts] and restore on [dispose].
/// - If no global controller exists yet, create a temporary one (tagged
///   'user_player') and register it untagged so [ReelItem] can find it;
///   then delete it on [dispose].
class UserShortsPlayer extends StatefulWidget {
  final List<ShortModel> shorts;
  final int initialIndex;

  const UserShortsPlayer({
    super.key,
    required this.shorts,
    required this.initialIndex,
  });

  @override
  State<UserShortsPlayer> createState() => _UserShortsPlayerState();
}

class _UserShortsPlayerState extends State<UserShortsPlayer> {
  late int _currentIndex;

  /// Whether we created a temporary controller (and thus must delete it on dispose).
  bool _createdTempCtrl = false;

  /// The original shorts from the global controller — restored on dispose.
  List<ShortModel>? _originalShorts;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    if (Get.isRegistered<ShortsController>()) {
      // Global controller exists — borrow it temporarily.
      final ctrl = Get.find<ShortsController>();
      _originalShorts = ctrl.shorts.toList();
      ctrl.shorts.assignAll(widget.shorts);
      ctrl.isTabVisible(true);
    } else {
      // No global controller — create a temporary one.
      Get.put(ShortsController(Get.find<ShortRepository>()));
      _createdTempCtrl = true;
      final ctrl = Get.find<ShortsController>();
      ctrl.shorts.assignAll(widget.shorts);
      ctrl.isTabVisible(true);
    }
  }

  @override
  void dispose() {
    if (_createdTempCtrl) {
      Get.find<ShortsController>().isTabVisible(false);
      Get.delete<ShortsController>();
    } else if (Get.isRegistered<ShortsController>()) {
      final ctrl = Get.find<ShortsController>();
      ctrl.isTabVisible(false);
      if (_originalShorts != null) {
        ctrl.shorts.assignAll(_originalShorts!);
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: widget.shorts.length,
        controller: PageController(initialPage: _currentIndex),
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (_, i) => ReelItem(
          key: ValueKey(widget.shorts[i].id),
          short: widget.shorts[i],
          isActive: i == _currentIndex,
        ),
      ),
    );
  }
}
