import 'dart:io';

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
  int    _selectedLength = 60; // seconds
  bool   _flashOff = true;
  int    _selectedTab = 0; // 0 = REEL, 1 = TEMPLATES

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickGallery() async {
    final file = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (file != null) _openCaption(file);
  }

  Future<void> _pickCamera() async {
    final file = await ImagePicker().pickVideo(source: ImageSource.camera);
    if (file != null) _openCaption(file);
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
      Navigator.pop(context); // close caption sheet
      Navigator.pop(context); // close create screen
    }
  }

  void _showLengthPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Video length',
                  style: TextStyle(color: Colors.white,
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              for (final s in [15, 30, 60, 90])
                ListTile(
                  title: Text('$s seconds',
                      style: const TextStyle(color: Colors.white)),
                  trailing: _selectedLength == s
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                  onTap: () {
                    setState(() => _selectedLength = s);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

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
          // ── Camera placeholder / black background ──────────────
          const SizedBox.expand(child: ColoredBox(color: Colors.black)),

          // ── Top bar ────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                      onTap: () => setState(() => _flashOff = !_flashOff),
                    ),
                    const SizedBox(width: 10),
                    // Speed
                    _TopControlChip(
                      label: '1×',
                      onTap: () {},
                    ),
                    const SizedBox(width: 10),
                    // Timer
                    _TopControlChip(
                      icon: Icons.timer_outlined,
                      onTap: () {},
                    ),
                    const Spacer(),
                    // Settings
                    _IconBtn(
                      icon: Icons.settings_outlined,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Add audio pill ─────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 64,
            left: 0, right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.music_note_rounded,
                          color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text('Add audio',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Left tools ────────────────────────────────────────
          Positioned(
            left: 20,
            top: 0, bottom: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ToolItem(
                    icon: Icons.music_note_outlined,
                    label: 'Audio',
                    onTap: () {},
                  ),
                  const SizedBox(height: 28),
                  _ToolItem(
                    icon: Icons.auto_awesome_outlined,
                    label: 'Effects',
                    onTap: () {},
                  ),
                  const SizedBox(height: 28),
                  _ToolItem(
                    customIcon: _LengthIcon(seconds: _selectedLength),
                    label: 'Length',
                    onTap: _showLengthPicker,
                  ),
                  const SizedBox(height: 28),
                  _ToolItem(
                    icon: Icons.person_search_outlined,
                    label: 'Green Screen',
                    onTap: () {},
                  ),
                  const SizedBox(height: 28),
                  _ToolItem(
                    icon: Icons.notes_rounded,
                    label: 'Teleprompter',
                    badge: 'NEW',
                    onTap: () {},
                  ),
                  const SizedBox(height: 28),
                  _ToolItem(
                    icon: Icons.auto_fix_high_outlined,
                    label: 'Touch Up',
                    badge: 'NEW',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom area ───────────────────────────────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Record row
                Padding(
                  padding: EdgeInsets.only(
                    left: 24, right: 24, bottom: 16,
                    top: 8,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Gallery thumbnail
                      GestureDetector(
                        onTap: _pickGallery,
                        child: Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: const Icon(Icons.photo_library_outlined,
                              color: Colors.white, size: 22),
                        ),
                      ),

                      const Spacer(),

                      // Record button
                      GestureDetector(
                        onTap: _pickCamera,
                        child: const _RecordButton(),
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
                          child: const Icon(Icons.flip_camera_ios_outlined,
                              color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),

                // REEL / TEMPLATES tab bar
                Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 8,
                    top: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TabLabel(
                        label: 'REEL',
                        selected: _selectedTab == 0,
                        onTap: () => setState(() => _selectedTab = 0),
                      ),
                      const SizedBox(width: 28),
                      _TabLabel(
                        label: 'TEMPLATES',
                        selected: _selectedTab == 1,
                        onTap: () => setState(() => _selectedTab = 1),
                      ),
                    ],
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

// ─── Record button ────────────────────────────────────────────────────────────

class _RecordButton extends StatelessWidget {
  const _RecordButton();

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

// ─── Top icon button ──────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}

// ─── Top control chip (flash / speed / timer) ─────────────────────────────────

class _TopControlChip extends StatelessWidget {
  final IconData?    icon;
  final String?      label;
  final VoidCallback onTap;
  const _TopControlChip({this.icon, this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: icon != null
            ? Icon(icon, color: Colors.white, size: 18)
            : Text(label ?? '',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ─── Left tool item ───────────────────────────────────────────────────────────

class _ToolItem extends StatelessWidget {
  final IconData?    icon;
  final Widget?      customIcon;
  final String       label;
  final String?      badge;
  final VoidCallback onTap;

  const _ToolItem({
    this.icon,
    this.customIcon,
    required this.label,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 34, height: 34,
            child: customIcon ??
                Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 26),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
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
              if (badge != null) const SizedBox(height: 2),
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
}

// ─── Length icon (circle with number) ────────────────────────────────────────

class _LengthIcon extends StatelessWidget {
  final int seconds;
  const _LengthIcon({required this.seconds});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        '$seconds',
        style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ─── Tab label ────────────────────────────────────────────────────────────────

class _TabLabel extends StatelessWidget {
  final String       label;
  final bool         selected;
  final VoidCallback onTap;
  const _TabLabel(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white38,
              fontSize: 14,
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w500,
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
