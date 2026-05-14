import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/models/story_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/local_storage.dart';
import '../../../data/repositories/story_repository.dart';
import '../models/story_viewer_item.dart';
import '../models/story_viewer_user.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<StoryViewerUser> users;
  final int initialUserIndex;

  const StoryViewerScreen({
    super.key,
    required this.users,
    required this.initialUserIndex,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late PageController pageController;
  late int currentUserIndex;
  int currentStoryIndex = 0;
  Timer? timer;
  bool showHeart   = false;
  bool isTyping    = false;
  bool isSending   = false;
  final Map<String, bool> likedStories = {};
  double progress   = 0;
  double dragOffset = 0;
  double edgeOffset = 0;
  VideoPlayerController? videoController;
  final TextEditingController messageController = TextEditingController();
  String? latestMessage;
  String? _myUserId;

  StoryViewerUser get currentUser => widget.users[currentUserIndex];
  StoryViewerItem get currentStory => currentUser.stories[currentStoryIndex];

  bool get _isMyStory =>
      _myUserId != null && currentUser.userId == _myUserId;

  @override
  void initState() {
    super.initState();
    currentUserIndex = widget.initialUserIndex;
    pageController = PageController(initialPage: widget.initialUserIndex);
    widget.users[currentUserIndex].viewed = true;
    _loadStory();
    LocalStorage.user.then((u) {
      if (mounted) setState(() => _myUserId = u?.id);
    });
  }

  void _loadStory() async {
    timer?.cancel();
    videoController?.dispose();
    videoController = null;
    progress = 0;

    final story = currentStory;

    if (story.type == StoryViewerType.video) {
      final ctrl = story.isNetwork
          ? VideoPlayerController.networkUrl(Uri.parse(story.media))
          : VideoPlayerController.asset(story.media);
      videoController = ctrl;
      await ctrl.initialize();
      ctrl..play()..setLooping(false);
      setState(() {});
      timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
        if (!mounted || videoController == null) return;
        final pos = videoController!.value.position.inMilliseconds;
        final dur = videoController!.value.duration.inMilliseconds;
        if (dur > 0) {
          setState(() { progress = pos / dur; });
          if (progress >= 1) { t.cancel(); _nextStory(); }
        }
      });
    } else {
      timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
        if (!mounted) return;
        setState(() { progress += 0.01; });
        if (progress >= 1) { t.cancel(); _nextStory(); }
      });
    }
  }

  void _nextStory() {
    if (currentStoryIndex < currentUser.stories.length - 1) {
      setState(() { currentStoryIndex++; });
      _loadStory();
    } else if (currentUserIndex < widget.users.length - 1) {
      pageController.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (currentStoryIndex > 0) {
      setState(() { currentStoryIndex--; });
      _loadStory();
    } else if (currentUserIndex == 0) {
      Navigator.pop(context);
    } else {
      pageController.previousPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
    }
  }

  void _pauseStory() {
    timer?.cancel();
    videoController?.pause();
  }

  void _resumeStory() {
    if (currentStory.type == StoryViewerType.image) {
      timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
        if (!mounted) return;
        setState(() { progress += 0.01; });
        if (progress >= 1) { t.cancel(); _nextStory(); }
      });
    } else {
      videoController?.play();
      timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
        if (!mounted || videoController == null) return;
        final pos = videoController!.value.position.inMilliseconds;
        final dur = videoController!.value.duration.inMilliseconds;
        if (dur > 0) setState(() { progress = pos / dur; });
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    videoController?.dispose();
    pageController.dispose();
    messageController.dispose();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    super.dispose();
  }

  Future<void> _sendReply(String value) async {
    final text = value.trim();
    if (text.isEmpty || isSending) return;

    setState(() { isSending = true; isTyping = false; });
    messageController.clear();
    FocusScope.of(context).unfocus();
    _resumeStory();

    final storyId = currentStory.storyId;
    final repo    = Get.find<StoryRepository>();
    final res     = await repo.replyToStory(storyId, text);

    if (!mounted) return;
    setState(() { isSending = false; });

    if (res.success && res.data != null) {
      // Navigate to the DM chat with the story owner
      Navigator.pop(context);
      Get.toNamed(AppRoutes.CHAT, arguments: res.data);
    } else {
      Get.snackbar('Error', res.error ?? 'Could not send reply',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _deleteStory(String storyId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete story?'),
        content: const Text('This story will be permanently deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    _pauseStory();
    final repo = Get.find<StoryRepository>();
    final res  = await repo.deleteStory(storyId);
    if (!mounted) return;
    if (res.success) {
      Navigator.pop(context);
      Get.snackbar('Deleted', 'Story deleted',
          snackPosition: SnackPosition.BOTTOM);
    } else {
      _resumeStory();
      Get.snackbar('Error', res.error ?? 'Failed to delete',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _showViewersList(BuildContext context, String storyId) async {
    _pauseStory();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StoryViewersSheet(storyId: storyId),
    );
    _resumeStory();
  }

  ImageProvider _profileImage(StoryViewerUser user) {
    if (user.isNetworkImage || user.profileImage.startsWith('http')) {
      return NetworkImage(user.profileImage);
    }
    return AssetImage(user.profileImage);
  }

  Widget _buildMedia(StoryViewerUser user, StoryViewerItem story, int pageIndex) {
    if (story.type == StoryViewerType.image) {
      final img = (story.isNetwork || story.media.startsWith('http'))
          ? Image.network(story.media, fit: BoxFit.cover, width: double.infinity, height: double.infinity,
              errorBuilder: (_, _, _) => const Center(child: Icon(Icons.broken_image, color: Colors.white30, size: 80)))
          : Image.asset(story.media, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
      return SizedBox.expand(child: img);
    }
    if (videoController != null && currentUserIndex == pageIndex && videoController!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: videoController!.value.size.width,
              height: videoController!.value.size.height,
              child: VideoPlayer(videoController!),
            ),
          ),
        ),
      );
    }
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildShareUser(String username) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 22, backgroundColor: Colors.white24,
              child: Text(username[0].toUpperCase(), style: const TextStyle(color: Colors.white))),
          const SizedBox(width: 14),
          Expanded(child: Text(username, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: const Text('Send', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnStoryBar(BuildContext context, StoryViewerUser user, StoryViewerItem story) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showViewersList(context, story.storyId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Seen by people',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _deleteStory(story.storyId),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildReplyBar(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.38),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: messageController,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    textAlignVertical: TextAlignVertical.center,
                    onTap: () {
                      if (!isTyping) { setState(() { isTyping = true; }); _pauseStory(); }
                    },
                    onSubmitted: (value) => _sendReply(value),
                    decoration: InputDecoration(
                      hintText: 'Send message...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 15),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
              ),
              if (isSending)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                )
              else if (!isTyping) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      likedStories[currentStory.media] = !(likedStories[currentStory.media] ?? false);
                    });
                  },
                  child: Icon(
                    (likedStories[currentStory.media] ?? false)
                        ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: (likedStories[currentStory.media] ?? false)
                        ? const Color(0xFFFF4D6D) : Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    _pauseStory();
                    await showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.black,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
                      builder: (ctx) => Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          _buildShareUser('mara.s'),
                          _buildShareUser('ona'),
                        ]),
                      ),
                    );
                    _resumeStory();
                  },
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 30),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryPage(StoryViewerUser user, int pageIndex) {
    final story = user.stories[currentStoryIndex.clamp(0, user.stories.length - 1)];
    return Stack(
      children: [
        Positioned.fill(child: _buildMedia(user, story, pageIndex)),

        Positioned(top: 0, left: 0, right: 0,
          child: IgnorePointer(child: Container(height: 180,
            decoration: BoxDecoration(gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.black.withValues(alpha: 0.65), Colors.transparent],
            ))))),

        Positioned(left: 0, right: 0, bottom: 0,
          child: IgnorePointer(child: Container(height: 240,
            decoration: BoxDecoration(gradient: LinearGradient(
              begin: Alignment.bottomCenter, end: Alignment.topCenter,
              colors: [Colors.black.withValues(alpha: 0.75), Colors.transparent],
            ))))),

        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 14, right: 14,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      children: List.generate(user.stories.length, (si) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: si < currentStoryIndex ? 1
                                  : si == currentStoryIndex && currentUserIndex == pageIndex ? progress
                                  : 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.7), blurRadius: 8)],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _pauseStory();
                      Get.toNamed(
                        AppRoutes.OTHER_PROFILE,
                        arguments: UserModel(
                          id: '',
                          email: '',
                          username: user.username,
                          profilePic: user.isNetworkImage ? user.profileImage : null,
                        ),
                      )?.then((_) => _resumeStory());
                    },
                    child: Row(
                      children: [
                        CircleAvatar(radius: 22, backgroundImage: _profileImage(user)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.username, style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14,
                                shadows: [Shadow(blurRadius: 8, color: Colors.black)])),
                            const SizedBox(height: 2),
                            Text(story.time, style: const TextStyle(
                                color: Colors.white70, fontSize: 12,
                                shadows: [Shadow(blurRadius: 8, color: Colors.black)])),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 21),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Center(
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: showHeart ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              child: const Icon(Icons.favorite_rounded, color: Color(0xFFFF4D6D), size: 110,
                  shadows: [Shadow(blurRadius: 40, color: Color(0x8CFF4D6D))]),
            ),
          ),
        ),

        if (latestMessage != null)
          Positioned(
            bottom: 110, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Text(latestMessage!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),

        Positioned(
          left: 16, right: 16, bottom: 18,
          child: SafeArea(
            child: _isMyStory
                ? _buildOwnStoryBar(context, currentUser, story)
                : _buildReplyBar(context),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (d) {
        if (currentUserIndex == 0 && d.delta.dx > 0) setState(() { edgeOffset += d.delta.dx; });
        else if (currentUserIndex == widget.users.length - 1 && d.delta.dx < 0) setState(() { edgeOffset += d.delta.dx; });
      },
      onHorizontalDragEnd: (_) {
        if (currentUserIndex == 0 && edgeOffset > 60) Navigator.pop(context);
        else if (currentUserIndex == widget.users.length - 1 && edgeOffset < -60) Navigator.pop(context);
        setState(() { edgeOffset = 0; });
      },
      onVerticalDragUpdate: (d) {
        setState(() { dragOffset += d.delta.dy; if (dragOffset < 0) dragOffset = 0; });
      },
      onVerticalDragEnd: (_) {
        if (dragOffset > 120) Navigator.pop(context);
        else setState(() { dragOffset = 0; });
      },
      onLongPressStart: (_) => _pauseStory(),
      onLongPressEnd:   (_) => _resumeStory(),
      onDoubleTap: () {
        setState(() { showHeart = true; likedStories[currentStory.media] = true; });
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) setState(() { showHeart = false; });
        });
      },
      onTapUp: (details) {
        if (isTyping) {
          FocusScope.of(context).unfocus();
          setState(() { isTyping = false; });
          _resumeStory();
          return;
        }
        final width = MediaQuery.of(context).size.width;
        if (details.globalPosition.dx < width / 2) _previousStory(); else _nextStory();
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: (1 - (dragOffset / 500)).clamp(0.7, 1),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: (1 - (dragOffset / 2000)).clamp(0.92, 1.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            transform: Matrix4.translationValues(edgeOffset, dragOffset, 0),
            child: Scaffold(
              backgroundColor: Colors.black,
              body: PageView.builder(
                controller: pageController,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() { currentUserIndex = index; currentStoryIndex = 0; });
                  widget.users[index].viewed = true;
                  _loadStory();
                },
                itemCount: widget.users.length,
                itemBuilder: (_, index) => _buildStoryPage(widget.users[index], index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Story Viewers Bottom Sheet ────────────────────────────────────────────────

class _StoryViewersSheet extends StatefulWidget {
  final String storyId;
  const _StoryViewersSheet({required this.storyId});
  @override
  State<_StoryViewersSheet> createState() => _StoryViewersSheetState();
}

class _StoryViewersSheetState extends State<_StoryViewersSheet> {
  List<StoryViewer> _viewers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = Get.find<StoryRepository>();
    final res  = await repo.getViewers(widget.storyId);
    if (mounted) setState(() { _viewers = res.data ?? []; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
          Row(
            children: [
              const Icon(Icons.remove_red_eye_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                '${_viewers.length} viewer${_viewers.length == 1 ? '' : 's'}',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator())
          else if (_viewers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No views yet',
                  style: TextStyle(color: Colors.grey)),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _viewers.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey[100]),
                itemBuilder: (_, i) {
                  final v = _viewers[i];
                  final u = v.user;
                  final name =
                      u.username ?? u.fullName ?? u.email.split('@').first;
                  final pic = u.profilePic;
                  final ago = _timeAgo(v.viewedAt);
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: pic != null && pic.isNotEmpty
                          ? NetworkImage(pic)
                          : null,
                      child: pic == null || pic.isEmpty
                          ? Text(
                              name.isNotEmpty
                                  ? name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12))
                          : null,
                    ),
                    title: Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    trailing: Text(ago,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  static String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inDays >= 1) return '${d.inDays}d ago';
    if (d.inHours >= 1) return '${d.inHours}h ago';
    if (d.inMinutes >= 1) return '${d.inMinutes}m ago';
    return 'just now';
  }
}
