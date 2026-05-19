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
  final _picker    = ImagePicker();
  File?  _selectedMedia;
  String _mediaType  = 'image';
  String _visibility = 'public';
  bool   _isUploading = false;
  String _username   = '';
  String _profilePic = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showSourcePicker());
  }

  Future<void> _loadUser() async {
    final me = await LocalStorage.user;
    if (mounted && me != null) {
      setState(() {
        _username   = me.username ?? me.fullName ?? 'You';
        _profilePic = me.profilePic ?? '';
      });
    }
  }

  Future<void> _showSourcePicker() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isDismissible: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 38, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Create Story',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            ListTile(
              leading: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: Colors.grey[100], shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_outlined),
              ),
              title: const Text('Camera',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Take a photo or video'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: Colors.grey[100], shape: BoxShape.circle),
                child: const Icon(Icons.photo_library_outlined),
              ),
              title: const Text('Gallery',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Choose a photo or video'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (!mounted) return;
    if (picked == 'camera') {
      await _showCameraTypePicker();
    } else if (picked == 'gallery') {
      await _showGalleryTypePicker();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showCameraTypePicker() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 38, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Camera',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            ListTile(
              leading: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: Colors.grey[100], shape: BoxShape.circle),
                child: const Icon(Icons.image_outlined),
              ),
              title: const Text('Photo', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(context, 'photo'),
            ),
            ListTile(
              leading: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: Colors.grey[100], shape: BoxShape.circle),
                child: const Icon(Icons.videocam_outlined),
              ),
              title: const Text('Video', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(context, 'video'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (picked == 'photo') {
      final file = await _picker.pickImage(source: ImageSource.camera);
      if (file != null) _openPreview(File(file.path), 'image');
      else if (mounted) Navigator.of(context).pop();
    } else if (picked == 'video') {
      final file = await _picker.pickVideo(source: ImageSource.camera);
      if (file != null) _openPreview(File(file.path), 'video');
      else if (mounted) Navigator.of(context).pop();
    } else if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showGalleryTypePicker() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 38, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Gallery',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            ListTile(
              leading: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: Colors.grey[100], shape: BoxShape.circle),
                child: const Icon(Icons.image_outlined),
              ),
              title: const Text('Photo', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(context, 'photo'),
            ),
            ListTile(
              leading: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: Colors.grey[100], shape: BoxShape.circle),
                child: const Icon(Icons.videocam_outlined),
              ),
              title: const Text('Video', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(context, 'video'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (picked == 'photo') {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) _openPreview(File(file.path), 'image');
      else if (mounted) Navigator.of(context).pop();
    } else if (picked == 'video') {
      final file = await _picker.pickVideo(source: ImageSource.gallery);
      if (file != null) _openPreview(File(file.path), 'video');
      else if (mounted) Navigator.of(context).pop();
    } else if (mounted) {
      Navigator.of(context).pop();
    }
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
          Navigator.pop(context);  // close sheet
          Navigator.pop(context);  // close screen
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

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.white);
  }
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
