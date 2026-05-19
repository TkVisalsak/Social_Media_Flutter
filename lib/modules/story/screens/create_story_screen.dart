import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/providers/local_storage.dart';
import '../../feed/controllers/story_feed_controller.dart';
import 'story_privacy_screen.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final _picker = ImagePicker();

  File?  _selectedMedia;
  String _mediaType  = 'image';
  String _visibility = 'public';
  bool   _isUploading = false;
  bool   _flashOff    = true;
  int    _selectedTab = 0; // 0=STORY, 1=BOOMERANG, 2=CREATE

  static const _tabs = ['STORY', 'BOOMERANG', 'CREATE'];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  String _username   = '';
  String _profilePic = '';

  Future<void> _loadUser() async {
    final me = await LocalStorage.user;
    if (mounted && me != null) {
      setState(() {
        _username   = me.username ?? me.fullName ?? 'You';
        _profilePic = me.profilePic ?? '';
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      _openPreview(File(photo.path), 'image');
      return;
    }
    // If photo dismissed, try video
  }

  Future<void> _pickVideoFromGallery() async {
    final video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) _openPreview(File(video.path), 'video');
  }

  Future<void> _capturePhoto() async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file != null) _openPreview(File(file.path), 'image');
  }

  Future<void> _captureVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.camera);
    if (file != null) _openPreview(File(file.path), 'video');
  }

  void _onCaptureTap() {
    if (_selectedTab == 0) {
      _capturePhoto();
    } else {
      _captureVideo();
    }
  }

  void _onGalleryTap() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined, color: Colors.white),
              title: const Text('Photo from gallery',
                  style: TextStyle(color: Colors.white)),
              onTap: () { Navigator.pop(context); _pickFromGallery(); },
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined, color: Colors.white),
              title: const Text('Video from gallery',
                  style: TextStyle(color: Colors.white)),
              onTap: () { Navigator.pop(context); _pickVideoFromGallery(); },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _openPreview(File file, String type) {
    setState(() {
      _selectedMedia = file;
      _mediaType     = type;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (_) => _StoryPreviewSheet(
        file: file,
        mediaType: type,
        visibility: _visibility,
        isUploading: _isUploading,
        username: _username,
        profilePic: _profilePic,
        onPrivacyTap: () async {
          final result = await Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (_) => const StoryPrivacyScreen()),
          );
          if (result != null) setState(() => _visibility = result);
        },
        onShare: _shareStory,
        onDiscard: () {
          setState(() => _selectedMedia = null);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _shareStory() async {
    if (_selectedMedia == null || _isUploading) return;
    setState(() => _isUploading = true);
    final ok = await Get.find<StoryFeedController>().createStory(
      filePath: _selectedMedia!.path,
      type: _mediaType,
      visibility: _visibility,
    );
    if (!mounted) return;
    setState(() => _isUploading = false);
    if (ok) {
      Navigator.pop(context); // close preview sheet
      Navigator.pop(context); // close create screen
    }
  }

  String get _visibilityLabel => switch (_visibility) {
        'friends'   => 'Friends',
        'private'   => 'Close Friends',
        'followers' => 'Followers',
        _           => 'Public',
      };

  IconData get _visibilityIcon => switch (_visibility) {
        'friends'   => Icons.people_rounded,
        'private'   => Icons.favorite_border_rounded,
        'followers' => Icons.person_outline_rounded,
        _           => Icons.public_rounded,
      };

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Black camera placeholder ────────────────────────────
          const SizedBox.expand(child: ColoredBox(color: Colors.black)),

          // ── Top bar ─────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    // Close
                    _IconBtn(
                      icon: Icons.close,
                      onTap: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    // Flash
                    _TopControlChip(
                      icon: _flashOff
                          ? Icons.flash_off_rounded
                          : Icons.flash_on_rounded,
                      onTap: () =>
                          setState(() => _flashOff = !_flashOff),
                    ),
                    const SizedBox(width: 10),
                    // Timer
                    _TopControlChip(
                      icon: Icons.timer_outlined,
                      onTap: () {},
                    ),
                    const Spacer(),
                    // Privacy chip
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const StoryPrivacyScreen()),
                        );
                        if (result != null) {
                          setState(() => _visibility = result);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_visibilityIcon,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 5),
                            Text(_visibilityLabel,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(width: 3),
                            const Icon(Icons.keyboard_arrow_down,
                                color: Colors.white54, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Left tools ──────────────────────────────────────────
          Positioned(
            left: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ToolItem(
                    icon: Icons.text_fields_rounded,
                    label: 'Text',
                    onTap: () {},
                  ),
                  const SizedBox(height: 28),
                  _ToolItem(
                    icon: Icons.draw_outlined,
                    label: 'Draw',
                    onTap: () {},
                  ),
                  const SizedBox(height: 28),
                  _ToolItem(
                    icon: Icons.emoji_emotions_outlined,
                    label: 'Sticker',
                    onTap: () {},
                  ),
                  const SizedBox(height: 28),
                  _ToolItem(
                    icon: Icons.add_link_rounded,
                    label: 'Link',
                    onTap: () {},
                  ),
                  const SizedBox(height: 28),
                  _ToolItem(
                    icon: Icons.music_note_outlined,
                    label: 'Audio',
                    onTap: () {},
                  ),
                  const SizedBox(height: 28),
                  _ToolItem(
                    icon: Icons.auto_fix_high_outlined,
                    label: 'Filter',
                    badge: 'NEW',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom area ─────────────────────────────────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Capture row
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Gallery thumbnail
                      GestureDetector(
                        onTap: _onGalleryTap,
                        child: Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: const Icon(
                              Icons.photo_library_outlined,
                              color: Colors.white,
                              size: 22),
                        ),
                      ),

                      const Spacer(),

                      // Capture button
                      GestureDetector(
                        onTap: _onCaptureTap,
                        child: const _CaptureButton(),
                      ),

                      const Spacer(),

                      // Flip camera
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 48, height: 48,
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                              Icons.flip_camera_ios_outlined,
                              color: Colors.white,
                              size: 24),
                        ),
                      ),
                    ],
                  ),
                ),

                // STORY / BOOMERANG / CREATE tabs
                Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.only(
                    bottom:
                        MediaQuery.of(context).padding.bottom + 8,
                    top: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_tabs.length, (i) {
                      final gap = i < _tabs.length - 1
                          ? const SizedBox(width: 28)
                          : const SizedBox.shrink();
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _TabLabel(
                            label: _tabs[i],
                            selected: _selectedTab == i,
                            onTap: () =>
                                setState(() => _selectedTab = i),
                          ),
                          gap,
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Capture button (photo-style: single ring) ────────────────────────────────

class _CaptureButton extends StatelessWidget {
  const _CaptureButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84, height: 84,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 84, height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
          ),
          Container(
            width: 66, height: 66,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reused widgets (same as CreateShortScreen) ───────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      );
}

class _TopControlChip extends StatelessWidget {
  final IconData?    icon;
  final VoidCallback onTap;
  const _TopControlChip({this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      );
}

class _ToolItem extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final String?      badge;
  final VoidCallback onTap;

  const _ToolItem({
    required this.icon,
    required this.label,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 34, height: 34,
              child: Icon(icon,
                  color: Colors.white.withValues(alpha: 0.85), size: 26),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFF404040),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(badge!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      );
}

class _TabLabel extends StatelessWidget {
  final String       label;
  final bool         selected;
  final VoidCallback onTap;
  const _TabLabel(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white38,
                fontSize: 14,
                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            if (selected)
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 28, height: 2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
      );
}

// ─── Story preview / upload sheet ─────────────────────────────────────────────

class _StoryPreviewSheet extends StatefulWidget {
  final File       file;
  final String     mediaType;
  final String     visibility;
  final bool       isUploading;
  final String     username;
  final String     profilePic;
  final VoidCallback onPrivacyTap;
  final VoidCallback onShare;
  final VoidCallback onDiscard;

  const _StoryPreviewSheet({
    required this.file,
    required this.mediaType,
    required this.visibility,
    required this.isUploading,
    required this.username,
    required this.profilePic,
    required this.onPrivacyTap,
    required this.onShare,
    required this.onDiscard,
  });

  @override
  State<_StoryPreviewSheet> createState() => _StoryPreviewSheetState();
}

class _StoryPreviewSheetState extends State<_StoryPreviewSheet> {
  String get _visibilityLabel => switch (widget.visibility) {
        'friends'   => 'Friends',
        'private'   => 'Close Friends',
        'followers' => 'Followers',
        _           => 'Public',
      };

  IconData get _visibilityIcon => switch (widget.visibility) {
        'friends'   => Icons.people_rounded,
        'private'   => Icons.favorite_border_rounded,
        'followers' => Icons.person_outline_rounded,
        _           => Icons.public_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      child: Stack(
        children: [
          // ── Media preview fills the whole sheet ──────────────
          Positioned.fill(
            child: widget.mediaType == 'image'
                ? Image.file(widget.file, fit: BoxFit.cover)
                : Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.video_file_rounded,
                              color: Colors.white54, size: 72),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32),
                            child: Text(
                              widget.file.path.split('/').last,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // ── Dark gradient at top ──────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: 130,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Dark gradient at bottom ───────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: 160,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Top bar ───────────────────────────────────────────
          Positioned(
            top: topPad + 8,
            left: 14, right: 14,
            child: Row(
              children: [
                // Back / discard
                GestureDetector(
                  onTap: widget.onDiscard,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
                const Spacer(),
                // Privacy chip
                GestureDetector(
                  onTap: widget.onPrivacyTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_visibilityIcon,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 5),
                        Text(_visibilityLabel,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 3),
                        const Icon(Icons.keyboard_arrow_down,
                            color: Colors.white54, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom share button ───────────────────────────────
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 16,
            left: 16, right: 16,
            child: Row(
              children: [
                // User avatar + name
                if (widget.profilePic.isNotEmpty)
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(widget.profilePic),
                  )
                else
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    child: Text(
                      widget.username.isNotEmpty
                          ? widget.username[0].toUpperCase()
                          : 'Y',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13),
                    ),
                  ),
                const SizedBox(width: 10),
                Text(
                  widget.username,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                // Share button
                widget.isUploading
                    ? const SizedBox(
                        width: 48, height: 48,
                        child: Center(
                          child: SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white),
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: widget.onShare,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Share to story',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_ios_rounded,
                                  color: Colors.black, size: 14),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
