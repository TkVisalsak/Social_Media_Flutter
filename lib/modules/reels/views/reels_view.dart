import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../controllers/reels_controller.dart';

class ReelsView extends GetView<ReelsController> {
  const ReelsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Background placeholder (replace with video later)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF141414), Color(0xFF000000)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                        size: 90, color: Colors.white70),
                  ),
                ),
              ),
            ),

            // Top bar
            Positioned(
              left: 8,
              top: 8,
              right: 8,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {},
                  ),
                  const Spacer(),
                  const Text(
                    'Video',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon:
                        const Icon(Icons.tune_rounded, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Right actions
            Positioned(
              right: 10,
              bottom: 110,
              child: Column(
                children: const [
                  _RightAction(icon: Icons.favorite_border, count: '5000'),
                  SizedBox(height: 18),
                  _RightAction(icon: Icons.chat_bubble_outline, count: '6000'),
                  SizedBox(height: 18),
                  _RightAction(icon: Icons.repeat, count: '200'),
                  SizedBox(height: 18),
                  _RightAction(icon: Icons.send_outlined, count: '7000'),
                ],
              ),
            ),

            // Bottom left (author + caption)
            Positioned(
              left: 12,
              right: 84,
              bottom: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white12,
                        child:
                            Icon(Icons.person, size: 16, color: Colors.white70),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'm.a.a.m.e',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified,
                          color: Color(0xFF1877F2), size: 16),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Text(
                          'Follow',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Lorem metus porttitor purus enim. Non et m…',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.music_note, color: Colors.white70, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Lorem metus porttitor pur…',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.person_outline,
                          color: Colors.white70, size: 18),
                      const SizedBox(width: 6),
                      const Text('55 users',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNav(current: _NavTab.reels),
    );
  }
}

enum _NavTab { feed, reels, direct, profile }

class _BottomNav extends StatelessWidget {
  final _NavTab current;
  const _BottomNav({required this.current});

  @override
  Widget build(BuildContext context) {
    Color iconColor(_NavTab tab) =>
        tab == current ? Colors.white : Colors.white70;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Color(0xFF1F1F1F), width: 0.5)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home_filled, color: iconColor(_NavTab.feed)),
                onPressed: () => Get.offAllNamed(AppRoutes.FEED),
              ),
              IconButton(
                icon: Icon(Icons.video_collection_outlined,
                    color: iconColor(_NavTab.reels)),
                onPressed: () => Get.offAllNamed(AppRoutes.REELS),
              ),
              IconButton(
                icon: Icon(Icons.send_outlined, color: iconColor(_NavTab.direct)),
                onPressed: () => Get.offAllNamed(AppRoutes.DIRECT),
              ),
              IconButton(
                icon: Icon(Icons.person_outline,
                    color: iconColor(_NavTab.profile)),
                onPressed: () => Get.offAllNamed(AppRoutes.PROFILE),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RightAction extends StatelessWidget {
  final IconData icon;
  final String count;
  const _RightAction({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 6),
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

