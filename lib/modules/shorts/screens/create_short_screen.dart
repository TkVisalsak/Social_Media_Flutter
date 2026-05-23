import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../controllers/shorts_controller.dart';

class CreateShortScreen extends StatefulWidget {
  const CreateShortScreen({super.key});

  @override
  State<CreateShortScreen> createState() => _CreateShortScreenState();
}

class _CreateShortScreenState extends State<CreateShortScreen> {
  final _captionCtrl = TextEditingController();
  XFile? _video;
  bool   _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showSourcePicker());
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
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
              child: Text('Create Reel',
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
              subtitle: const Text('Record a new video'),
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
              subtitle: const Text('Choose from your videos'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (!mounted) return;
    if (picked == 'camera') {
      await _pickCamera();
    } else if (picked == 'gallery') {
      await _pickGallery();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickGallery() async {
    final file = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (file != null) {
      _openCaption(file);
    } else if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickCamera() async {
    final file = await ImagePicker().pickVideo(source: ImageSource.camera);
    if (file != null) {
      _openCaption(file);
    } else if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _openCaption(XFile file) {
    setState(() => _video = file);
    // Resolve the observable before the sheet builds to avoid Get.find
    // being called inside the modal builder's isolated context.
    final uploadProgress = Get.find<ShortsController>().uploadProgress;
    // Capture top padding here — the modal strips it from its inner MediaQuery.
    final topPad = MediaQuery.paddingOf(context).top;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (_) => _CaptionSheet(
        file: file,
        captionCtrl: _captionCtrl,
        uploadProgress: uploadProgress,
        topPad: topPad,
        onShare: _upload,
        onDiscard: () {
          setState(() => _video = null);
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _upload() async {
    if (_video == null || _isUploading) return;
    setState(() => _isUploading = true);

    final ok = await Get.find<ShortsController>().createShort(
      filePath: _video!.path,
      caption: _captionCtrl.text.trim().isEmpty
          ? null
          : _captionCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isUploading = false);
    if (ok) {
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.white);
  }
}

// ─── Caption / upload sheet ───────────────────────────────────────────────────

class _CaptionSheet extends StatefulWidget {
  final XFile                 file;
  final TextEditingController captionCtrl;
  final RxDouble              uploadProgress;
  final double                topPad;
  final VoidCallback          onShare;
  final VoidCallback          onDiscard;

  const _CaptionSheet({
    required this.file,
    required this.captionCtrl,
    required this.uploadProgress,
    required this.topPad,
    required this.onShare,
    required this.onDiscard,
  });

  @override
  State<_CaptionSheet> createState() => _CaptionSheetState();
}

class _CaptionSheetState extends State<_CaptionSheet> {
  Uint8List? _thumbnail;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    final bytes = await VideoThumbnail.thumbnailData(
      video: widget.file.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 720,
      quality: 80,
    );
    if (mounted) setState(() => _thumbnail = bytes);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final inset     = MediaQuery.viewInsetsOf(context).bottom;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      child: Stack(
        children: [
          // ── Video thumbnail as background ─────────────────────
          Positioned.fill(
            child: _thumbnail != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(_thumbnail!, fit: BoxFit.cover),
                      const Center(
                        child: IgnorePointer(
                          child: Icon(Icons.play_circle_outline_rounded,
                              color: Colors.white38, size: 72),
                        ),
                      ),
                    ],
                  )
                : const ColoredBox(
                    color: Colors.black,
                    child: Center(
                      child: CircularProgressIndicator(
                          color: Colors.white38, strokeWidth: 1.5),
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
            height: 220,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Upload progress overlay ───────────────────────────
          Positioned.fill(
            child: Obx(() {
              final progress = widget.uploadProgress.value;
              if (progress < 0) return const SizedBox.shrink();
              return IgnorePointer(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.45),
                ),
              );
            }),
          ),

          // ── Top bar ───────────────────────────────────────────
          Positioned(
            top: widget.topPad + 8,
            left: 14, right: 14,
            child: Row(
              children: [
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
                const Text('New Reel',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                // Invisible placeholder to keep title centred
                const SizedBox(width: 40),
              ],
            ),
          ),

          // ── Bottom: caption field + share row ─────────────────
          Positioned(
            bottom: bottomPad + inset + 16,
            left: 16, right: 16,
            child: Obx(() {
              final progress  = widget.uploadProgress.value;
              final uploading = progress >= 0;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Caption field — hidden while uploading
                  if (!uploading)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: TextField(
                        controller: widget.captionCtrl,
                        style: const TextStyle(color: Colors.white),
                        autofocus: false,
                        decoration: const InputDecoration(
                          hintText: 'Write a caption…',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                        maxLines: 3,
                        minLines: 1,
                      ),
                    ),

                  // Share / progress row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (uploading)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: Colors.white38),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 80,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.white24,
                                    color: Colors.white,
                                    minHeight: 4,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        )
                      else
                        GestureDetector(
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
                                Text('Share reel',
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
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
