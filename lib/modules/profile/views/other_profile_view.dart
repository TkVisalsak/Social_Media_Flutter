import 'package:flutter/material.dart';

class OtherProfileView extends StatelessWidget {
  final String username;
  final String profileImage;
  final bool   isNetworkImage;

  const OtherProfileView({
    super.key,
    required this.username,
    required this.profileImage,
    this.isNetworkImage = true,
  });

  ImageProvider _resolveImage() {
    if (profileImage.isEmpty) return const AssetImage('assets/images/placeholder.png');
    if (isNetworkImage || profileImage.startsWith('http')) return NetworkImage(profileImage);
    return AssetImage(profileImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(username, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22)),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 24, 10),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: CircleAvatar(
                              radius: 42,
                              backgroundColor: Colors.grey[100],
                              backgroundImage: profileImage.isNotEmpty ? _resolveImage() : null,
                              child: profileImage.isEmpty
                                  ? Text(username.isNotEmpty ? username[0].toUpperCase() : '?',
                                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold))
                                  : null,
                            ),
                          ),
                          const Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _StatItem(label: 'Posts',     value: '48'),
                                _StatItem(label: 'Followers', value: '12.4K'),
                                _StatItem(label: 'Following', value: '384'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(username, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          const Text('Digital Creator', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          const SizedBox(height: 2),
                          const Text('Living the dream ✨', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(child: _ProfileButton(label: 'Follow', filled: true, onPressed: () {})),
                          const SizedBox(width: 8),
                          Expanded(child: _ProfileButton(label: 'Message', onPressed: () {})),
                          const SizedBox(width: 8),
                          _ProfileIconButton(icon: Icons.person_add_outlined, onPressed: () {}),
                        ],
                      ),
                    ),

                    const _HighlightsSection(),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  const TabBar(
                    indicatorColor: Colors.black,
                    indicatorWeight: 1,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(icon: Icon(Icons.grid_on)),
                      Tab(icon: Icon(Icons.video_collection_outlined)),
                      Tab(icon: Icon(Icons.person_pin_outlined)),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildPhotoGrid(),
              const Center(child: Text('No Reels yet')),
              const Center(child: Text('Photos and videos of you')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return Image.network(
          'https://picsum.photos/id/${username.hashCode.abs() % 50 + index + 1}/300/300',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(color: Colors.grey[200]),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black)),
      ],
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onPressed;
  const _ProfileButton({required this.label, required this.onPressed, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: filled ? Colors.black : Colors.grey[100],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
        ),
        child: Text(label,
            style: TextStyle(color: filled ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600, fontSize: 14)),
      ),
    );
  }
}

class _ProfileIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _ProfileIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: IconButton(
        icon: Icon(icon, size: 18, color: Colors.black),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _HighlightsSection extends StatelessWidget {
  const _HighlightsSection();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 1,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(right: 18),
          child: Column(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey[200]!)),
                child: const Icon(Icons.add, size: 30),
              ),
              const SizedBox(height: 6),
              const Text('New', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override double get minExtent => _tabBar.preferredSize.height;
  @override double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate old) => false;
}
