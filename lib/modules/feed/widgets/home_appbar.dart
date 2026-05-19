import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../notifications/controllers/notifications_controller.dart';
import '../../shorts/screens/create_short_screen.dart';
import '../../story/screens/create_story_screen.dart';
import '../controllers/feed_controller.dart';
import '../screens/create_post_screen.dart';
import 'create_fab.dart';

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
                'TosChat',
                style: TextStyle(
                  fontSize: 32,
                  fontFamily: 'Cookie',
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            _CreateDropdownButton(
              items: [
                CreateMenuItem(
                  icon: Icons.edit_note_rounded,
                  label: 'New post',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CreatePostScreen())),
                ),
                CreateMenuItem(
                  icon: Icons.auto_stories_rounded,
                  label: 'Story',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CreateStoryScreen())),
                ),
                CreateMenuItem(
                  icon: Icons.video_library_rounded,
                  label: 'Reel',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CreateShortScreen())),
                ),
              ],
            ),
            IconButton(
              onPressed: () => Get.toNamed(AppRoutes.FRIEND_SUGGESTIONS),
              icon: const Icon(Icons.people_outline_rounded, size: 26),
              splashRadius: 22,
            ),
            const SizedBox(width: 4),
            Obx(() {
              final notifCtrl = Get.find<NotificationsController>();
              final count = notifCtrl.unreadCount;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: controller.openNotifications,
                    icon: const Icon(CupertinoIcons.bell, size: 26),
                    splashRadius: 22,
                  ),
                  if (count > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF4D6D),
                          shape: BoxShape.circle,
                        ),
                        constraints:
                            const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Dropdown create button ───────────────────────────────────────────────────

class _CreateDropdownButton extends StatefulWidget {
  final List<CreateMenuItem> items;
  const _CreateDropdownButton({required this.items});

  @override
  State<_CreateDropdownButton> createState() => _CreateDropdownButtonState();
}

class _CreateDropdownButtonState extends State<_CreateDropdownButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _sheetScale;
  late final Animation<double> _sheetOpacity;
  late final Animation<double> _iconRotation;

  OverlayEntry? _overlay;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _sheetScale = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );
    _sheetOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.6),
      reverseCurve: const Interval(0.4, 1.0),
    );
    _iconRotation = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() => _isOpen ? _close() : _open();

  void _open() {
    setState(() => _isOpen = true);
    _ctrl.forward();
    _insertOverlay();
  }

  void _close() {
    _ctrl.reverse().whenComplete(() {
      _removeOverlay();
      if (mounted) setState(() => _isOpen = false);
    });
  }

  void _insertOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final btnOffset = renderBox.localToGlobal(Offset.zero);
    final btnSize   = renderBox.size;
    final screenW   = MediaQuery.sizeOf(context).width;
    // Right-align the menu with the right edge of the button
    final menuRight = screenW - btnOffset.dx - btnSize.width;

    _overlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // Transparent scrim — dismisses on tap
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _close,
            ),
          ),
          // Dropdown menu positioned just below the button
          Positioned(
            top: btnOffset.dy + btnSize.height + 6,
            right: menuRight,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, child) => Opacity(
                opacity: _sheetOpacity.value,
                child: Transform.scale(
                  scale: 0.5 + 0.5 * _sheetScale.value,
                  alignment: Alignment.topRight,
                  child: child,
                ),
              ),
              child: _DropdownSheet(
                items: widget.items,
                progress: _ctrl,
                onItemTap: (item) {
                  _close();
                  item.onTap();
                },
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlay!);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: AnimatedBuilder(
          animation: _iconRotation,
          builder: (_, __) => Transform.rotate(
            angle: _iconRotation.value * 2 * 3.1415926,
            child: Icon(
              _isOpen
                  ? Icons.add_circle_rounded
                  : Icons.add_circle_outline_rounded,
              size: 28,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Dropdown sheet ───────────────────────────────────────────────────────────

class _DropdownSheet extends StatelessWidget {
  const _DropdownSheet({
    required this.items,
    required this.progress,
    required this.onItemTap,
  });

  final List<CreateMenuItem> items;
  final Animation<double> progress;
  final ValueChanged<CreateMenuItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200, width: 0.5),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < items.length; i++)
              _DropdownItem(
                index: i,
                progress: progress,
                child: _DropdownRow(
                  item: items[i],
                  onTap: () => onItemTap(items[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Items slide DOWN into place (offset goes from -12 → 0).
class _DropdownItem extends StatelessWidget {
  const _DropdownItem({
    required this.index,
    required this.progress,
    required this.child,
  });

  final int index;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = 0.15 + (index * 0.08);
    final end   = (start + 0.50).clamp(0.0, 1.0);
    final anim  = CurvedAnimation(
      parent: progress,
      curve: Interval(start, end, curve: Curves.easeOut),
    );

    return AnimatedBuilder(
      animation: anim,
      builder: (_, child) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, -12 * (1 - anim.value)), // slides from above
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _DropdownRow extends StatelessWidget {
  const _DropdownRow({required this.item, required this.onTap});

  final CreateMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(item.icon, size: 20, color: Colors.black87),
            const SizedBox(width: 12),
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
