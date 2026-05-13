import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/shorts_controller.dart';

class CreateShortScreen extends StatefulWidget {
  const CreateShortScreen({super.key});

  @override
  State<CreateShortScreen> createState() => _CreateShortScreenState();
}

class _CreateShortScreenState extends State<CreateShortScreen> {
  final _captionCtrl = TextEditingController();
  XFile?  _video;
  bool    _isUploading = false;

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickGallery() async {
    final file = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (file != null) setState(() => _video = file);
  }

  Future<void> _pickCamera() async {
    final file = await ImagePicker().pickVideo(source: ImageSource.camera);
    if (file != null) setState(() => _video = file);
  }

  Future<void> _upload() async {
    if (_video == null || _isUploading) return;
    setState(() => _isUploading = true);

    final ok = await Get.find<ShortsController>().createShort(
      filePath: _video!.path,
      caption:  _captionCtrl.text.trim().isEmpty
          ? null
          : _captionCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isUploading = false);
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final canUpload = _video != null && !_isUploading;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('New Reel',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFF8B5CF6)),
              ),
            )
          else
            TextButton(
              onPressed: canUpload ? _upload : null,
              child: Text(
                'Share',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: canUpload
                      ? const Color(0xFF8B5CF6)
                      : Colors.grey,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Video preview ────────────────────────
            Expanded(
              child: _video == null
                  ? _PickerPlaceholder(
                      onGallery: _pickGallery,
                      onCamera:  _pickCamera,
                    )
                  : _VideoPreview(
                      file:      _video!,
                      onReplace: () => setState(() => _video = null),
                    ),
            ),

            // ── Caption field ────────────────────────
            Container(
              color: const Color(0xFF111111),
              padding: EdgeInsets.only(
                left: 16, right: 16, top: 12,
                bottom: 12 + MediaQuery.viewInsetsOf(context).bottom +
                    MediaQuery.paddingOf(context).bottom,
              ),
              child: TextField(
                controller: _captionCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Add a caption...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                ),
                maxLines: 3,
                minLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pick placeholder ─────────────────────────────────────────────────────────

class _PickerPlaceholder extends StatelessWidget {
  final VoidCallback onGallery;
  final VoidCallback onCamera;
  const _PickerPlaceholder(
      {required this.onGallery, required this.onCamera});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.video_library_outlined,
              color: Colors.white38, size: 80),
          const SizedBox(height: 20),
          const Text('Select a video to share',
              style: TextStyle(color: Colors.white54, fontSize: 16)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PickBtn(
                icon:  Icons.photo_library_rounded,
                label: 'Gallery',
                color: const Color(0xFF8B5CF6),
                onTap: onGallery,
              ),
              const SizedBox(width: 20),
              _PickBtn(
                icon:  Icons.videocam_rounded,
                label: 'Camera',
                color: const Color(0xFF6366F1),
                onTap: onCamera,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PickBtn extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final Color        color;
  final VoidCallback onTap;
  const _PickBtn(
      {required this.icon, required this.label,
       required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}

// ─── Video preview ────────────────────────────────────────────────────────────

class _VideoPreview extends StatelessWidget {
  final XFile        file;
  final VoidCallback onReplace;
  const _VideoPreview({required this.file, required this.onReplace});

  @override
  Widget build(BuildContext context) {
    final name = file.path.split('/').last;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.video_file_rounded,
                  color: Color(0xFF8B5CF6), size: 72),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Video selected ✓',
                  style: TextStyle(
                      color: Color(0xFF8B5CF6),
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Positioned(
          top: 32, right: 32,
          child: GestureDetector(
            onTap: onReplace,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                  color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}
