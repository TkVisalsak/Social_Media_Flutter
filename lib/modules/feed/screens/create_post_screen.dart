import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';

// ─── Audience enum ────────────────────────────────────────────────────────────

enum PostAudience { public, friends, friendsExcept, specificFriends, onlyMe }

extension _AudienceX on PostAudience {
  String get label => switch (this) {
        PostAudience.public          => 'Public',
        PostAudience.friends         => 'Friends',
        PostAudience.friendsExcept   => 'Friends except...',
        PostAudience.specificFriends => 'Specific friends',
        PostAudience.onlyMe          => 'Only me',
      };

  IconData get icon => switch (this) {
        PostAudience.public          => Icons.public_rounded,
        PostAudience.friends         => Icons.people_rounded,
        PostAudience.friendsExcept   => Icons.person_remove_rounded,
        PostAudience.specificFriends => Icons.person_add_rounded,
        PostAudience.onlyMe          => Icons.lock_rounded,
      };

  String get description => switch (this) {
        PostAudience.public          => 'Anyone on or off Social',
        PostAudience.friends         => 'Your friends on Social',
        PostAudience.friendsExcept   => 'Don\'t show to some friends',
        PostAudience.specificFriends => 'Only show to some friends',
        PostAudience.onlyMe          => 'Only visible to you',
      };
}

// ─── Mock data ────────────────────────────────────────────────────────────────

const _feelings = [
  ('😊', 'Happy'),    ('😢', 'Sad'),       ('😍', 'Loved'),
  ('💪', 'Motivated'),('😂', 'Amused'),    ('😎', 'Cool'),
  ('🥳', 'Excited'),  ('😴', 'Tired'),     ('😤', 'Proud'),
  ('🤔', 'Curious'),  ('😡', 'Frustrated'),('🙏', 'Grateful'),
  ('🥰', 'Blessed'),  ('😰', 'Worried'),   ('🎉', 'Celebrating'),
];

const _mockLocations = [
  (icon: Icons.location_on,        label: 'Paris, France'),
  (icon: Icons.location_on,        label: 'New York, NY'),
  (icon: Icons.location_on,        label: 'Tokyo, Japan'),
  (icon: Icons.location_on,        label: 'London, UK'),
  (icon: Icons.location_on,        label: 'Sydney, Australia'),
  (icon: Icons.location_on,        label: 'Los Angeles, CA'),
  (icon: Icons.location_on,        label: 'Berlin, Germany'),
  (icon: Icons.my_location_rounded, label: 'Use current location'),
];

class _TagContact {
  final String name;
  final String avatar;
  const _TagContact({required this.name, required this.avatar});
}

const _tagContacts = [
  _TagContact(name: 'Iko',           avatar: 'assets/images/story2.jpg'),
  _TagContact(name: 'Jules H.',      avatar: 'assets/images/post3.jpg'),
  _TagContact(name: 'Mara S.',       avatar: 'assets/images/post6.jpg'),
  _TagContact(name: 'Ona',           avatar: 'assets/images/story1.jpg'),
  _TagContact(name: 'Lev P.',        avatar: 'assets/images/post7.jpg'),
  _TagContact(name: 'Danny K.',      avatar: 'assets/images/post8.jpg'),
  _TagContact(name: 'Raffialdo',     avatar: 'assets/images/story3.jpg'),
  _TagContact(name: 'Debora',        avatar: 'assets/images/post4.jpg'),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _textCtrl = TextEditingController();

  PostAudience     _audience = PostAudience.public;
  List<XFile>      _images   = [];
  List<String>     _tagged   = [];
  String?          _feeling;
  String?          _location;

  @override
  void initState() {
    super.initState();
    _textCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  // ── Computed ─────────────────────────────────────────────────────────────────

  bool get _canPost => _textCtrl.text.trim().isNotEmpty || _images.isNotEmpty;

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _pickImages() async {
    final files = await ImagePicker().pickMultiImage();
    if (files.isNotEmpty) setState(() => _images = files);
  }

  Future<void> _pickCamera() async {
    final file = await ImagePicker().pickImage(source: ImageSource.camera);
    if (file != null) setState(() => _images = [..._images, file]);
  }

  Future<void> _pickAudience() async {
    final result = await showModalBottomSheet<PostAudience>(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => _AudienceSheet(current: _audience),
    );
    if (result != null) setState(() => _audience = result);
  }

  Future<void> _pickFeeling() async {
    final result = await showModalBottomSheet<String>(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => _FeelingSheet(current: _feeling),
    );
    if (result != null) setState(() => _feeling = result);
  }

  Future<void> _pickLocation() async {
    final result = await showModalBottomSheet<String>(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => _LocationSheet(current: _location),
    );
    if (result != null) setState(() => _location = result);
  }

  Future<void> _tagPeople() async {
    final result = await showModalBottomSheet<List<String>>(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => _TagPeopleSheet(current: _tagged),
    );
    if (result != null) setState(() => _tagged = result);
  }

  void _submitPost() {
    // TODO: integrate with controller
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:  const Text('Post shared!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape:    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──────────────────────────────────────────────────
            _AppBar(canPost: _canPost, onPost: _submitPost),
            const Divider(height: 1, thickness: 0.5),

            // ── Scrollable content ────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User info row
                    _UserRow(audience: _audience, onAudienceTap: _pickAudience),
                    const SizedBox(height: 4),

                    // Text field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _textCtrl,
                        maxLines:   null,
                        autofocus:  true,
                        style:      const TextStyle(fontSize: 17, height: 1.5),
                        decoration: const InputDecoration(
                          hintText:    "What's on your mind?",
                          hintStyle:   TextStyle(color: Colors.grey, fontSize: 17),
                          border:      InputBorder.none,
                          isCollapsed: true,
                        ),
                      ),
                    ),

                    // Active badges (feeling / location / tagged)
                    if (_feeling != null || _location != null || _tagged.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Wrap(
                          spacing:    8,
                          runSpacing: 8,
                          children: [
                            if (_feeling != null)
                              _Badge(
                                label:   _feeling!,
                                color:   const Color(0xFFFFF3CD),
                                onClose: () => setState(() => _feeling = null),
                              ),
                            if (_location != null)
                              _Badge(
                                label:   '📍 $_location',
                                color:   const Color(0xFFFFE8E8),
                                onClose: () => setState(() => _location = null),
                              ),
                            if (_tagged.isNotEmpty)
                              _Badge(
                                label:   '🏷 ${_tagged.join(', ')}',
                                color:   const Color(0xFFE8F0FE),
                                onClose: () => setState(() => _tagged = []),
                              ),
                          ],
                        ),
                      ),

                    // Media preview
                    if (_images.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _MediaGrid(
                        images:   _images,
                        onRemove: (i) => setState(() => _images.removeAt(i)),
                      ),
                    ],

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Add-to-post bar ───────────────────────────────────────────
            _AddToPostBar(
              onPhoto:    _pickImages,
              onCamera:   _pickCamera,
              onTag:      _tagPeople,
              onFeeling:  _pickFeeling,
              onLocation: _pickLocation,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App bar ──────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final bool         canPost;
  final VoidCallback onPost;
  const _AppBar({required this.canPost, required this.onPost});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon:      const Icon(Icons.close_rounded, size: 26),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Create post',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity:  canPost ? 1.0 : 0.45,
              child: ElevatedButton(
                onPressed: canPost ? onPost : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation:       0,
                  padding:         const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Post', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── User row ─────────────────────────────────────────────────────────────────

class _UserRow extends StatelessWidget {
  final PostAudience audience;
  final VoidCallback onAudienceTap;
  const _UserRow({required this.audience, required this.onAudienceTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          const CircleAvatar(
            radius:          22,
            backgroundImage: AssetImage('assets/images/story1.jpg'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TkVisalsak',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 4),
              // Audience chip
              GestureDetector(
                onTap: onAudienceTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:        Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                    border:       Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(audience.icon, size: 13, color: Colors.black87),
                      const SizedBox(width: 5),
                      Text(
                        audience.label,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Active badge ─────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String       label;
  final Color        color;
  final VoidCallback onClose;
  const _Badge({required this.label, required this.color, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close_rounded, size: 15, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

// ─── Media grid ───────────────────────────────────────────────────────────────

class _MediaGrid extends StatelessWidget {
  final List<XFile>      images;
  final void Function(int) onRemove;
  const _MediaGrid({required this.images, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap:  true,
        physics:     const NeverScrollableScrollPhysics(),
        itemCount:   images.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: images.length == 1 ? 1 : 2,
          crossAxisSpacing: 4,
          mainAxisSpacing:  4,
          childAspectRatio: images.length == 1 ? 4 / 3 : 1,
        ),
        itemBuilder: (_, i) => Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(File(images[i].path), fit: BoxFit.cover),
            ),
            Positioned(
              top: 6, right: 6,
              child: GestureDetector(
                onTap: () => onRemove(i),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add-to-post bar ──────────────────────────────────────────────────────────

class _AddToPostBar extends StatelessWidget {
  final VoidCallback onPhoto;
  final VoidCallback onCamera;
  final VoidCallback onTag;
  final VoidCallback onFeeling;
  final VoidCallback onLocation;

  const _AddToPostBar({
    required this.onPhoto,
    required this.onCamera,
    required this.onTag,
    required this.onFeeling,
    required this.onLocation,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color:  Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: bottomPad + 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12, bottom: 8),
            child: Text(
              'Add to your post',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black54),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BarBtn(icon: Icons.photo_library_rounded,    color: const Color(0xFF45BD62), label: 'Photo',    onTap: onPhoto),
              _BarBtn(icon: Icons.camera_alt_rounded,       color: const Color(0xFF1877F2), label: 'Camera',   onTap: onCamera),
              _BarBtn(icon: Icons.person_add_rounded,       color: const Color(0xFF1778F2), label: 'Tag',      onTap: onTag),
              _BarBtn(icon: Icons.emoji_emotions_outlined,  color: const Color(0xFFF7B928), label: 'Feeling',  onTap: onFeeling),
              _BarBtn(icon: Icons.location_on_rounded,      color: const Color(0xFFE02B2B), label: 'Check-in', onTap: onLocation),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarBtn extends StatelessWidget {
  final IconData     icon;
  final Color        color;
  final String       label;
  final VoidCallback onTap;
  const _BarBtn({required this.icon, required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color:        color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black54)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHEETS
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Audience sheet ───────────────────────────────────────────────────────────

class _AudienceSheet extends StatefulWidget {
  final PostAudience current;
  const _AudienceSheet({required this.current});

  @override
  State<_AudienceSheet> createState() => _AudienceSheetState();
}

class _AudienceSheetState extends State<_AudienceSheet> {
  late PostAudience _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Stack(
            alignment: Alignment.center,
            children: [
              const Text('Select audience', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              Positioned(
                right: 8,
                child: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Text(
              'Who can see your post?',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const Divider(height: 1, thickness: 0.5),

          // Options
          ...PostAudience.values.map((a) => _AudienceOption(
            audience: a,
            selected: _selected == a,
            onTap:    () => setState(() => _selected = a),
          )),

          const SizedBox(height: 12),

          // Done button
          Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, bottomPad + 12),
            child: SizedBox(
              width:  double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _selected),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation:       0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AudienceOption extends StatelessWidget {
  final PostAudience audience;
  final bool         selected;
  final VoidCallback onTap;
  const _AudienceOption({required this.audience, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color:        selected ? const Color(0xFFE8F0FE) : Colors.grey[100],
                shape:        BoxShape.circle,
              ),
              child: Icon(audience.icon, color: selected ? AppColors.primaryBlue : Colors.black87, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(audience.label,      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(audience.description, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primaryBlue : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.primaryBlue : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 15)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Feeling sheet ────────────────────────────────────────────────────────────

class _FeelingSheet extends StatefulWidget {
  final String? current;
  const _FeelingSheet({required this.current});

  @override
  State<_FeelingSheet> createState() => _FeelingSheetState();
}

class _FeelingSheetState extends State<_FeelingSheet> {
  String? _selected;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.toLowerCase()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<(String, String)> get _filtered => _query.isEmpty
      ? _feelings
      : _feelings.where((f) => f.$2.toLowerCase().contains(_query)).toList();

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 14),

          Stack(
            alignment: Alignment.center,
            children: [
              const Text('How are you feeling?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              Positioned(
                right: 8,
                child: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 40,
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText:       'Search feelings...',
                  hintStyle:      TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon:     Icon(Icons.search, color: Colors.grey[400], size: 20),
                  border:         InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5),

          // Grid
          Expanded(
            child: GridView.builder(
              padding:     const EdgeInsets.all(12),
              itemCount:   _filtered.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:   3,
                childAspectRatio: 1.1,
                crossAxisSpacing: 8,
                mainAxisSpacing:  8,
              ),
              itemBuilder: (_, i) {
                final (emoji, label) = _filtered[i];
                final isSelected = _selected == '$emoji $label';
                return GestureDetector(
                  onTap: () {
                    setState(() => _selected = '$emoji $label');
                    Future.delayed(const Duration(milliseconds: 150), () {
                      if (context.mounted) Navigator.pop(context, '$emoji $label');
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color:        isSelected ? const Color(0xFFFFF3CD) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(14),
                      border:       Border.all(
                        color: isSelected ? const Color(0xFFF7B928) : Colors.grey[200]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize:   12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: bottomPad),
        ],
      ),
    );
  }
}

// ─── Location sheet ───────────────────────────────────────────────────────────

class _LocationSheet extends StatefulWidget {
  final String? current;
  const _LocationSheet({required this.current});

  @override
  State<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<_LocationSheet> {
  final _searchCtrl = TextEditingController();
  String  _query    = '';
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.toLowerCase()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<({IconData icon, String label})> get _filtered => _query.isEmpty
      ? _mockLocations
      : _mockLocations.where((l) => l.label.toLowerCase().contains(_query)).toList();

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 14),

          Stack(
            alignment: Alignment.center,
            children: [
              const Text('Add check-in', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              Positioned(
                right: 8,
                child: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 42,
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
              child: TextField(
                controller: _searchCtrl,
                autofocus:  true,
                decoration: InputDecoration(
                  hintText:       'Search for a place...',
                  hintStyle:      TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon:     const Icon(Icons.search, color: Colors.grey, size: 20),
                  border:         InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 0.5),

          // Results
          Expanded(
            child: ListView.builder(
              itemCount:   _filtered.length,
              itemBuilder: (_, i) {
                final loc        = _filtered[i];
                final isSelected = _selected == loc.label;
                return ListTile(
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color:  isSelected ? const Color(0xFFFFE8E8) : Colors.grey[100],
                      shape:  BoxShape.circle,
                    ),
                    child: Icon(loc.icon, color: isSelected ? const Color(0xFFE02B2B) : Colors.black54, size: 20),
                  ),
                  title: Text(loc.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF0095F6))
                      : null,
                  onTap: () => Navigator.pop(context, loc.label),
                );
              },
            ),
          ),
          SizedBox(height: bottomPad),
        ],
      ),
    );
  }
}

// ─── Tag people sheet ─────────────────────────────────────────────────────────

class _TagPeopleSheet extends StatefulWidget {
  final List<String> current;
  const _TagPeopleSheet({required this.current});

  @override
  State<_TagPeopleSheet> createState() => _TagPeopleSheetState();
}

class _TagPeopleSheetState extends State<_TagPeopleSheet> {
  final _searchCtrl = TextEditingController();
  late final Set<String> _selected;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.current);
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.toLowerCase()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_TagContact> get _filtered => _query.isEmpty
      ? _tagContacts
      : _tagContacts.where((c) => c.name.toLowerCase().contains(_query)).toList();

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 14),

          Stack(
            alignment: Alignment.center,
            children: [
              const Text('Tag people', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              Positioned(
                right: 8,
                child: TextButton(
                  onPressed: () => Navigator.pop(context, _selected.toList()),
                  child: const Text('Done', style: TextStyle(color: Color(0xFF0095F6), fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Selected chips
          if (_selected.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:         const EdgeInsets.symmetric(horizontal: 16),
                children: _selected.map((name) {
                  final contact = _tagContacts.where((c) => c.name == name).firstOrNull;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      avatar:           contact != null
                          ? CircleAvatar(backgroundImage: AssetImage(contact.avatar), radius: 12)
                          : null,
                      label:            Text(name, style: const TextStyle(fontSize: 12)),
                      onDeleted:        () => setState(() => _selected.remove(name)),
                      deleteIconColor:  Colors.grey,
                      backgroundColor:  const Color(0xFFE8F0FE),
                      padding:          EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                }).toList(),
              ),
            ),

          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText:       'Search friends...',
                  hintStyle:      TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon:     Icon(Icons.search, color: Colors.grey[400], size: 20),
                  border:         InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 0.5),

          // Contact list
          Expanded(
            child: ListView.builder(
              itemCount:   _filtered.length,
              itemBuilder: (_, i) {
                final c          = _filtered[i];
                final isSelected = _selected.contains(c.name);
                return ListTile(
                  leading: CircleAvatar(radius: 22, backgroundImage: AssetImage(c.avatar)),
                  title:   Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  trailing: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      shape:  BoxShape.circle,
                      color:  isSelected ? AppColors.primaryBlue : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppColors.primaryBlue : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 15)
                        : null,
                  ),
                  onTap: () => setState(() {
                    isSelected ? _selected.remove(c.name) : _selected.add(c.name);
                  }),
                );
              },
            ),
          ),
          SizedBox(height: bottomPad),
        ],
      ),
    );
  }
}
