import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../controllers/shorts_controller.dart';
import '../screens/create_short_screen.dart';
import '../widgets/reel_item.dart';

class ShortsView extends GetView<ShortsController> {
  const ShortsView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Content (loading/empty/reels) — always in background
          Obx(() {
            if (controller.isLoading.value && controller.shorts.isEmpty) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            }
            if (controller.shorts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.video_library_outlined,
                        size: 64, color: Colors.white38),
                    const SizedBox(height: 16),
                    Text(controller.error.value ?? 'No reels yet',
                        style: const TextStyle(color: Colors.white54)),
                  ],
                ),
              );
            }
            return _ReelPageView(controller: controller);
          }),
          // TopBar always on top — user can always toggle FYP/Friends
          _TopBar(),
        ],
      ),
    );
  }
}

class _ReelPageView extends StatefulWidget {
  final ShortsController controller;
  const _ReelPageView({required this.controller});

  @override
  State<_ReelPageView> createState() => _ReelPageViewState();
}

class _ReelPageViewState extends State<_ReelPageView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Obx(() => PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: widget.controller.shorts.length,
      onPageChanged: (i) => setState(() => _currentIndex = i),
      itemBuilder: (_, i) => ReelItem(
        key: ValueKey(widget.controller.shorts[i].id),
        short: widget.controller.shorts[i],
        isActive: i == _currentIndex,
      ),
    ));
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShortsController>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // ── Plus / Create button ──────────────────────────
            GestureDetector(
              onTap: () {
                controller.isTabVisible(false);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateShortScreen(),
                  ),
                ).whenComplete(() => controller.isTabVisible(true));
              },
              child: const Icon(Icons.add_box_outlined, color: Colors.white, size: 28),
            ),
            const Spacer(),
            // ── FYP / Friends tab toggle (reactive) ───────────
            Obx(() {
              final feed = controller.selectedFeed.value;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TabBtn(
                    label:    'For You',
                    selected: feed == 'fyp',
                    onTap:    () => controller.switchFeed('fyp'),
                  ),
                  const SizedBox(width: 20),
                  _TabBtn(
                    label:    'Friends',
                    selected: feed == 'friends',
                    onTap:    () => controller.switchFeed('friends'),
                  ),
                ],
              );
            }),
            const Spacer(),
            // ── Search button ─────────────────────────────────
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.SEARCH),
              child: const Icon(Icons.search_rounded, color: Colors.white, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              )),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: selected ? 24 : 0,
            height: 2,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
