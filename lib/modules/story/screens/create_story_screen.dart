import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

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
  String _mediaType   = 'image';
  String _visibility  = 'public';
  bool   _isUploading = false;

  Future<void> _pickPhoto() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() { _selectedMedia = File(file.path); _mediaType = 'image'; });
  }

  Future<void> _pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) setState(() { _selectedMedia = File(file.path); _mediaType = 'video'; });
  }

  Future<void> _pickCamera() async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file != null) setState(() { _selectedMedia = File(file.path); _mediaType = 'image'; });
  }

  Future<void> _openPrivacy() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const StoryPrivacyScreen()),
    );
    if (result != null) setState(() => _visibility = result);
  }

  Future<void> _shareStory() async {
    if (_selectedMedia == null || _isUploading) return;
    setState(() => _isUploading = true);
    final ok = await Get.find<StoryFeedController>().createStory(
      filePath: _selectedMedia!.path, type: _mediaType, visibility: _visibility,
    );
    if (!mounted) return;
    setState(() => _isUploading = false);
    if (ok) Navigator.pop(context);
  }

  String get _visibilityLabel => switch (_visibility) {
        'friends'   => 'Friends',
        'private'   => 'Only me',
        'followers' => 'Followers',
        _           => 'Public',
      };

  IconData get _visibilityIcon => switch (_visibility) {
        'friends'   => Icons.people_rounded,
        'private'   => Icons.lock_rounded,
        'followers' => Icons.person_rounded,
        _           => Icons.public_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final hasMedia = _selectedMedia != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 28, color: Colors.black),
                  ),
                  const Spacer(),
                  const Text('Create story',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  GestureDetector(
                    onTap: _openPrivacy,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_visibilityIcon, size: 14, color: Colors.black87),
                          const SizedBox(width: 4),
                          Text(_visibilityLabel,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 2),
                          const Icon(Icons.keyboard_arrow_down, size: 15, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 16),

            // Type buttons (no media selected)
            if (!hasMedia) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    _TypeBtn(icon: Icons.image_rounded, label: 'Photo', onTap: _pickPhoto),
                    const SizedBox(width: 10),
                    _TypeBtn(icon: Icons.videocam_rounded, label: 'Video', onTap: _pickVideo),
                    const SizedBox(width: 10),
                    _TypeBtn(icon: Icons.text_fields_rounded, label: 'Text', onTap: () {}),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Main area
            Expanded(
              child: Stack(
                children: [
                  hasMedia
                      ? _MediaPreview(
                          file: _selectedMedia!,
                          mediaType: _mediaType,
                          onClear: () => setState(() => _selectedMedia = null),
                        )
                      : _EmptyState(onPickPhoto: _pickPhoto),
                  if (!hasMedia)
                    Positioned(
                      right: 20, bottom: 20,
                      child: GestureDetector(
                        onTap: _pickCamera,
                        child: Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 12, offset: const Offset(0, 4),
                            )],
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 26, color: Colors.black),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Share button
            if (hasMedia)
              Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16,
                    12 + MediaQuery.paddingOf(context).bottom),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _shareStory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isUploading
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : const Text('Share to story',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TypeBtn extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _TypeBtn({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.black),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onPickPhoto;
  const _EmptyState({required this.onPickPhoto});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onPickPhoto,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100], borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Tap to choose a photo or video',
                style: TextStyle(color: Colors.grey[500], fontSize: 15)),
          ],
        ),
      ),
    ),
  );
}

class _MediaPreview extends StatelessWidget {
  final File file; final String mediaType; final VoidCallback onClear;
  const _MediaPreview({required this.file, required this.mediaType, required this.onClear});
  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: mediaType == 'image'
              ? Image.file(file, fit: BoxFit.cover)
              : Container(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.video_file_rounded, color: Colors.white54, size: 64),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(file.path.split('/').last,
                              textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 2,
                              style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
      Positioned(
        top: 12, right: 24,
        child: GestureDetector(
          onTap: onClear,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
            child: const Icon(Icons.close, color: Colors.white, size: 18),
          ),
        ),
      ),
    ],
  );
}
