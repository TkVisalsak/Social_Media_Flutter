import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/user_model.dart';
import '../../../data/providers/local_storage.dart';

/// Facebook-style "Create" shortcuts and post composer overlay.
class FeedCreateFlow {
  FeedCreateFlow._();

  static Future<void> showOptions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        final bottom = MediaQuery.paddingOf(sheetCtx).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Material(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                clipBehavior: Clip.antiAlias,
                elevation: 8,
                shadowColor: Colors.black26,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                  child: Column(
                    children: [
                      const Text(
                        'Create',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
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
                              Navigator.pop(sheetCtx);
                              showPostOverlay(context);
                            },
                          ),
                          _CreateShortcut(
                            icon: Icons.auto_stories_rounded,
                            label: 'Story',
                            iconBg: const Color(0xFFE8F0FE),
                            iconColor: const Color(0xFF1877F2),
                            onTap: () {
                              Navigator.pop(sheetCtx);
                              _openStory(context);
                            },
                          ),
                          _CreateShortcut(
                            icon: Icons.video_library_rounded,
                            label: 'Reel',
                            iconBg: const Color(0xFFF3E8FF),
                            iconColor: const Color(0xFF8B5CF6),
                            onTap: () {
                              Navigator.pop(sheetCtx);
                              _openReel(context);
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
      },
    );
  }

  static void _openStory(BuildContext context) {
    Get.snackbar(
      'Story',
      'Story camera is not wired up yet.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
    // When route exists: Get.toNamed(AppRoutes.STORY);
  }

  static void _openReel(BuildContext context) {
    Get.snackbar(
      'Reel',
      'Reels are not wired up yet.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
    // When route exists: Get.toNamed(AppRoutes.REELS);
  }

  static Future<void> showPostOverlay(BuildContext context) async {
    final user = await LocalStorage.user;
    if (!context.mounted) return;
    final name = _displayName(user);

    await showGeneralDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _CreatePostOverlayPage(displayName: name);
      },
      transitionBuilder: (ctx, anim, _, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    );
  }

  static String _displayName(UserModel? u) {
    if (u == null) return 'You';
    for (final c in [u.username, u.name, u.email]) {
      final s = c?.trim();
      if (s != null && s.isNotEmpty) return s;
    }
    return 'You';
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
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreatePostOverlayPage extends StatefulWidget {
  final String displayName;

  const _CreatePostOverlayPage({required this.displayName});

  @override
  State<_CreatePostOverlayPage> createState() => _CreatePostOverlayPageState();
}

class _CreatePostOverlayPageState extends State<_CreatePostOverlayPage> {
  final _text = TextEditingController();
  bool _canPost = false;

  @override
  void initState() {
    super.initState();
    _text.addListener(() {
      final ok = _text.text.trim().isNotEmpty;
      if (ok != _canPost) setState(() => _canPost = ok);
    });
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    if (_text.text.trim().isEmpty) return;
    Navigator.of(context).pop();
    Get.snackbar(
      'Post',
      'Your update is ready to send when the API is connected.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height * 0.92;
    final inset = MediaQuery.viewInsetsOf(context).bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.white,
        elevation: 24,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: h,
          child: Padding(
            padding: EdgeInsets.only(bottom: inset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black87),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Expanded(
                        child: Text(
                          'Create post',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _canPost ? _submit : null,
                        child: Text(
                          'POST',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: _canPost
                                ? const Color(0xFF1877F2)
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFF1877F2),
                        child: Text(
                          widget.displayName.isNotEmpty
                              ? widget.displayName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F2F5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.people, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'Friends',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Icon(Icons.arrow_drop_down, size: 18),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _text,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      hintText: "What's on your mind?",
                      hintStyle: TextStyle(
                        fontSize: 18,
                        color: Colors.black45,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    style: const TextStyle(fontSize: 18, height: 1.35),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFE4E6EB)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ComposerAction(
                        icon: Icons.photo_library_outlined,
                        color: const Color(0xFF45BD62),
                        label: 'Photo',
                      ),
                      _ComposerAction(
                        icon: Icons.person_outline,
                        color: const Color(0xFF1877F2),
                        label: 'Tag',
                      ),
                      _ComposerAction(
                        icon: Icons.mood_outlined,
                        color: const Color(0xFFF7B928),
                        label: 'Feeling',
                      ),
                      _ComposerAction(
                        icon: Icons.location_on_outlined,
                        color: const Color(0xFFF02849),
                        label: 'Location',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.paddingOf(context).bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ComposerAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _ComposerAction({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
