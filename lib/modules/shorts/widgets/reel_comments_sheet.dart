import 'package:flutter/material.dart';

class ReelCommentsSheet extends StatefulWidget {
  final int commentCount;
  const ReelCommentsSheet({super.key, required this.commentCount});

  @override
  State<ReelCommentsSheet> createState() => _ReelCommentsSheetState();
}

class _ReelCommentsSheetState extends State<ReelCommentsSheet> {
  final _textController = TextEditingController();
  final List<_Comment> _comments = List.from(_seed);
  final Set<int> _liked = {};

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.add(_Comment(username: 'you', text: text, time: 'now', likes: 0));
      _textController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
          Text('${widget.commentCount} comments',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const Divider(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _comments.length,
              itemBuilder: (_, i) {
                final c = _comments[i];
                final liked = _liked.contains(i);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey[200],
                        child: Text(c.username[0].toUpperCase()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black, fontSize: 14),
                            children: [
                              TextSpan(text: '${c.username} ', style: const TextStyle(fontWeight: FontWeight.w700)),
                              TextSpan(text: c.text),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() { if (liked) _liked.remove(i); else _liked.add(i); }),
                        child: Column(
                          children: [
                            Icon(liked ? Icons.favorite : Icons.favorite_border,
                                size: 16, color: liked ? Colors.red : Colors.grey),
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
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(24)),
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(hintText: 'Add a comment...', border: InputBorder.none, isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _submit,
                    child: const Text('Post', style: TextStyle(color: Color(0xFF3797F0), fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Comment {
  final String username;
  final String text;
  final String time;
  final int likes;
  const _Comment({required this.username, required this.text, required this.time, required this.likes});
}

const _seed = <_Comment>[
  _Comment(username: 'iko',     text: 'This is fire 🔥',                    time: '2h',  likes: 234),
  _Comment(username: 'jules.h', text: 'Incredible — where is this?? 😍',     time: '3h',  likes: 89),
  _Comment(username: 'mara.s',  text: 'I need to go here ASAP',              time: '4h',  likes: 156),
];
