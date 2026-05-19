import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CaptionSheet(
        file: file,
        captionCtrl: _captionCtrl,
        isUploading: _isUploading,
        onShare: _upload,
        onDiscard: () {
          setState(() => _video = null);
          Navigator.pop(context);  // close sheet
          Navigator.pop(context);  // close screen
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
      Navigator.pop(context); // close caption sheet
      Navigator.pop(context); // close create screen
    }
  }

  @override
  Widget build(BuildContext context) {
    // Blank white background — the source picker and caption sheet float on top.
    return const Scaffold(backgroundColor: Colors.white);
  }
}

// ─── Caption / upload sheet ───────────────────────────────────────────────────

class _CaptionSheet extends StatefulWidget {
  final XFile                   file;
  final TextEditingController   captionCtrl;
  final bool                    isUploading;
  final VoidCallback            onShare;
  final VoidCallback            onDiscard;

  const _CaptionSheet({
    required this.file,
    required this.captionCtrl,
    required this.isUploading,
    required this.onShare,
    required this.onDiscard,
  });

  @override
  State<_CaptionSheet> createState() => _CaptionSheetState();
}

class _CaptionSheetState extends State<_CaptionSheet> {
  @override
  Widget build(BuildContext context) {
    final name = widget.file.path.split('/').last;
    final inset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 6),
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onDiscard,
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                ),
                const Spacer(),
                const Text('New Reel',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                widget.isUploading
                    ? const SizedBox(
                        width: 40, height: 20,
                        child: Center(
                          child: SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          ),
                        ),
                      )
                    : TextButton(
                        onPressed: widget.onShare,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          minimumSize: const Size(60, 34),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        child: const Text('Share',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                      ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          // Video file name preview
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 54, height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(Icons.video_file_rounded,
                      color: Colors.white54, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // Caption field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: widget.captionCtrl,
              style: const TextStyle(color: Colors.white),
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Write a caption...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
              maxLines: 3,
              minLines: 1,
            ),
          ),

          SizedBox(height: MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }
}
