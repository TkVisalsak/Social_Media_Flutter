import 'package:flutter/material.dart';

class PostCommentsSheet extends StatefulWidget {
  final String postId;
  const PostCommentsSheet({super.key, required this.postId});

  @override
  State<PostCommentsSheet> createState() => _PostCommentsSheetState();
}

class _PostCommentsSheetState extends State<PostCommentsSheet> {
  final _controller = TextEditingController();
  final List<_Comment> _comments = List.from(_seed);
  final Set<int> _liked = {};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.add(_Comment(username: 'you', avatar: null, text: text, time: 'now', likes: 0));
      _controller.clear();
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const Text('Comments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const Divider(height: 20),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    final c = _comments[index];
                    final liked = _liked.contains(index);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: c.avatar != null ? AssetImage(c.avatar!) : null,
                            child: c.avatar == null
                                ? Text(c.username[0].toUpperCase(), style: const TextStyle(fontSize: 14))
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(color: Colors.black, fontSize: 14),
                                    children: [
                                      TextSpan(text: '${c.username} ', style: const TextStyle(fontWeight: FontWeight.w700)),
                                      TextSpan(text: c.text),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(c.time, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (liked) _liked.remove(index); else _liked.add(index);
                              });
                            },
                            child: Column(
                              children: [
                                Icon(liked ? Icons.favorite : Icons.favorite_border,
                                    size: 16, color: liked ? Colors.red : Colors.grey),
                                const SizedBox(height: 2),
                                Text('${c.likes + (liked ? 1 : 0)}',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16, right: 16, bottom: 8,
                    top: 8 + MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: 'Add a comment...',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _submit,
                        child: const Text('Post',
                            style: TextStyle(color: Color(0xFF3797F0), fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Comment {
  final String username;
  final String? avatar;
  final String text;
  final String time;
  final int likes;
  const _Comment({required this.username, this.avatar, required this.text, required this.time, required this.likes});
}

const _seed = <_Comment>[
  _Comment(username: 'iko',     avatar: null, text: 'This is amazing! 🔥',            time: '2h',  likes: 234),
  _Comment(username: 'jules.h', avatar: null, text: 'Love this so much 😍',            time: '3h',  likes: 89),
  _Comment(username: 'mara.s',  avatar: null, text: 'Where is this place?',            time: '4h',  likes: 56),
  _Comment(username: 'ona',     avatar: null, text: 'Goals 🙌',                         time: '5h',  likes: 120),
];
