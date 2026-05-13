import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/feed_controller.dart';
import '../screens/create_post_screen.dart';

class HomeAppBar extends GetWidget<FeedController> {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 18, left: 20, right: 20, bottom: 14),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Social app',
                style: TextStyle(
                  fontSize: 32,
                  fontFamily: 'Cookie',
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            _PlusButton(onTap: () => _showCreateSheet(context)),
            const SizedBox(width: 4),
            IconButton(
              onPressed: controller.openNotifications,
              icon: const Icon(CupertinoIcons.bell, size: 26),
              splashRadius: 22,
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CreateBottomSheet(),
    );
  }
}

class _PlusButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PlusButton({required this.onTap});

  @override
  State<_PlusButton> createState() => _PlusButtonState();
}

class _PlusButtonState extends State<_PlusButton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _rotation = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _ctrl.forward();
        widget.onTap();
        _ctrl.forward().then((_) => Future.delayed(
          const Duration(milliseconds: 400), () { if (mounted) _ctrl.reverse(); }));
      },
      child: RotationTransition(
        turns: _rotation,
        child: const Icon(Icons.add_circle_outline_rounded, size: 28),
      ),
    );
  }
}

class _CreateBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
          ),
          Material(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            elevation: 8,
            shadowColor: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              child: Column(
                children: [
                  const Text('Create', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CreateShortcut(
                        icon: Icons.edit_note_rounded,
                        label: 'Post',
                        iconBg: const Color(0xFFE7F8EB),
                        iconColor: const Color(0xFF45BD62),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen()));
                        },
                      ),
                      _CreateShortcut(
                        icon: Icons.auto_stories_rounded,
                        label: 'Story',
                        iconBg: const Color(0xFFE8F0FE),
                        iconColor: const Color(0xFF1877F2),
                        onTap: () {
                          Navigator.pop(context);
                          Get.snackbar('Story', 'Create story coming soon', snackPosition: SnackPosition.BOTTOM);
                        },
                      ),
                      _CreateShortcut(
                        icon: Icons.video_library_rounded,
                        label: 'Reel',
                        iconBg: const Color(0xFFF3E8FF),
                        iconColor: const Color(0xFF8B5CF6),
                        onTap: () {
                          Navigator.pop(context);
                          Get.snackbar('Reel', 'Create reel coming soon', snackPosition: SnackPosition.BOTTOM);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateShortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _CreateShortcut({
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 30),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
