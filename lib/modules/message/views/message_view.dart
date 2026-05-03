import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../controllers/message_controller.dart';

class DirectView extends GetView<DirectController> {
  const DirectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.add, color: Colors.black),
          onPressed: () {},
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Socialappofficial',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _SearchBar(
              hintText: 'Search',
              onTap: () {},
            ),
            const SizedBox(height: 10),
            const _StoriesRow(),
            const SizedBox(height: 8),
            _MessagesHeader(
              onRequestTap: () {},
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 12),
                itemCount: _dummyMessages.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 2),
                itemBuilder: (context, i) {
                  final m = _dummyMessages[i];
                  return _MessageTile(
                    name: m.name,
                    subtitle: m.subtitle,
                    isActive: m.isActive,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNav(current: _NavTab.direct),
    );
  }
}

enum _NavTab { feed, reels, direct, profile }

class _BottomNav extends StatelessWidget {
  final _NavTab current;
  const _BottomNav({required this.current});

  @override
  Widget build(BuildContext context) {
    Color iconColor(_NavTab tab) =>
        tab == current ? Colors.black : Colors.black54;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 0.5)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home_filled, color: iconColor(_NavTab.feed)),
                onPressed: () => Get.offAllNamed(AppRoutes.FEED),
              ),
              IconButton(
                icon: Icon(Icons.video_collection_outlined,
                    color: iconColor(_NavTab.reels)),
                onPressed: () => Get.offAllNamed(AppRoutes.REELS),
              ),
              IconButton(
                icon: Icon(Icons.send_outlined, color: iconColor(_NavTab.direct)),
                onPressed: () => Get.offAllNamed(AppRoutes.DIRECT),
              ),
              IconButton(
                icon:
                    Icon(Icons.person_outline, color: iconColor(_NavTab.profile)),
                onPressed: () => Get.offAllNamed(AppRoutes.PROFILE),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final String hintText;
  final VoidCallback onTap;

  const _SearchBar({required this.hintText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFECECEC),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.black45),
              const SizedBox(width: 10),
              Text(
                hintText,
                style: const TextStyle(color: Colors.black45, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoriesRow extends StatelessWidget {
  const _StoriesRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _StoryItem(name: 'Your story', isOwn: true),
          _StoryItem(name: 'leo.messi', isOwn: false, isVerified: true),
          _StoryItem(name: 'cuifenn', isOwn: false),
          _StoryItem(name: '_.brainn', isOwn: false),
          _StoryItem(name: 'm.a.a.m', isOwn: false),
        ],
      ),
    );
  }
}

class _StoryItem extends StatelessWidget {
  final String name;
  final bool isOwn;
  final bool isVerified;

  const _StoryItem({
    required this.name,
    required this.isOwn,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isOwn
                      ? null
                      : const LinearGradient(
                          colors: [
                            Color(0xFFE91E8C),
                            Color(0xFF6C63FF),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color: isOwn ? Colors.grey[300] : null,
                ),
                padding: const EdgeInsets.all(2.5),
                child: CircleAvatar(
                  backgroundColor: Colors.grey[350],
                  child: Icon(Icons.person, color: Colors.grey[700], size: 26),
                ),
              ),
              if (isOwn)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1877F2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 14),
                  ),
                ),
              if (isVerified && !isOwn)
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: Icon(Icons.verified, color: Color(0xFF1877F2), size: 18),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 68,
            child: Text(
              name,
              style: const TextStyle(fontSize: 11, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessagesHeader extends StatelessWidget {
  final VoidCallback onRequestTap;

  const _MessagesHeader({required this.onRequestTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Row(
        children: [
          const Text(
            'Message',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onRequestTap,
            child: const Text(
              'Request',
              style: TextStyle(
                color: Color(0xFF1877F2),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final bool isActive;

  const _MessageTile({
    required this.name,
    required this.subtitle,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, color: Colors.grey[700]),
                  ),
                  if (isActive)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ECC71),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.photo_camera_outlined, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}

class _DummyMessage {
  final String name;
  final String subtitle;
  final bool isActive;

  const _DummyMessage(this.name, this.subtitle, {this.isActive = false});
}

const _dummyMessages = <_DummyMessage>[
  _DummyMessage('Jefferey Williams', 'Seen on Monday'),
  _DummyMessage('Talia Gomez', 'Seen on Wednesday'),
  _DummyMessage('Francis Ofori', 'Active 1hr ago', isActive: true),
  _DummyMessage('Jordan Amil', 'Active now', isActive: true),
  _DummyMessage('Jade Chen', 'Sent'),
  _DummyMessage('sombrero_dude', 'See you very soon. · 1w'),
];

