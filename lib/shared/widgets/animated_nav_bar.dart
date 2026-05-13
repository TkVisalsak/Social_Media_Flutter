import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NavItem {
  final IconData icon;
  final String label;
  const NavItem({required this.icon, required this.label});
}

class AnimatedNavBar extends StatefulWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const AnimatedNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  State<AnimatedNavBar> createState() => _AnimatedNavBarState();
}

class _AnimatedNavBarState extends State<AnimatedNavBar> {
  static const Color _accent = Color(0xFF5B4BFF);
  static const Color _pillBg = Color(0xFFEAE6FF);
  static const Color _inactive = Color(0xFF1A1A1A);

  final List<GlobalKey> _itemKeys = [];
  final GlobalKey _rowKey = GlobalKey();

  bool _isDragging = false;
  int _hoverIndex = -1;
  List<Rect> _itemRectSnapshot = const [];
  Rect? _rowRectSnapshot;

  @override
  void initState() {
    super.initState();
    _itemKeys.addAll(List.generate(widget.items.length, (_) => GlobalKey()));
  }

  @override
  void didUpdateWidget(covariant AnimatedNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length != _itemKeys.length) {
      _itemKeys
        ..clear()
        ..addAll(List.generate(widget.items.length, (_) => GlobalKey()));
    }
  }

  void _captureSnapshot() {
    final rects = <Rect>[];
    for (final key in _itemKeys) {
      final ctx = key.currentContext;
      final box = ctx?.findRenderObject() as RenderBox?;
      if (ctx == null || box == null || !box.hasSize) {
        rects.add(Rect.zero);
        continue;
      }
      final topLeft = box.localToGlobal(Offset.zero);
      rects.add(topLeft & box.size);
    }
    _itemRectSnapshot = rects;
    final rowBox = _rowKey.currentContext?.findRenderObject() as RenderBox?;
    if (rowBox != null && rowBox.hasSize) {
      _rowRectSnapshot = rowBox.localToGlobal(Offset.zero) & rowBox.size;
    } else {
      _rowRectSnapshot = null;
    }
  }

  int _indexAt(Offset globalPos) {
    if (_itemRectSnapshot.isEmpty) return -1;
    // Snap to row edges so dragging past the ends still selects the end item.
    final row = _rowRectSnapshot;
    if (row != null) {
      if (globalPos.dx <= row.left) return 0;
      if (globalPos.dx >= row.right) return _itemRectSnapshot.length - 1;
    }
    // Pick the item whose horizontal center is nearest to the pointer.
    // This is stable even if items resize underneath the finger.
    int best = _hoverIndex >= 0 ? _hoverIndex : 0;
    double bestDist = double.infinity;
    for (int i = 0; i < _itemRectSnapshot.length; i++) {
      final r = _itemRectSnapshot[i];
      if (r.width == 0) continue;
      final d = (globalPos.dx - r.center.dx).abs();
      if (d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    return best;
  }

  void _handleStart(Offset globalPos) {
    _captureSnapshot();
    final idx = _indexAt(globalPos);
    if (idx < 0) return;
    setState(() {
      _isDragging = true;
      _hoverIndex = idx;
    });
    HapticFeedback.selectionClick();
    if (idx != widget.selectedIndex) {
      widget.onChanged(idx);
    }
  }

  void _handleUpdate(Offset globalPos) {
    if (!_isDragging) return;
    final idx = _indexAt(globalPos);
    if (idx < 0 || idx == _hoverIndex) return;
    setState(() => _hoverIndex = idx);
    HapticFeedback.selectionClick();
    widget.onChanged(idx);
  }

  void _handleEnd() {
    if (!_isDragging) return;
    setState(() {
      _isDragging = false;
      _hoverIndex = -1;
    });
    _itemRectSnapshot = const [];
    _rowRectSnapshot = null;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) => _handleStart(e.position),
      onPointerMove: (e) => _handleUpdate(e.position),
      onPointerUp: (_) => _handleEnd(),
      onPointerCancel: (_) => _handleEnd(),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 65,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                key: _rowKey,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (int index = 0; index < widget.items.length; index++)
                    _NavBarItem(
                      key: _itemKeys[index],
                      item: widget.items[index],
                      isSelected: index == widget.selectedIndex,
                      isHovered: _isDragging && index == _hoverIndex,
                      accent: _accent,
                      pillBg: _pillBg,
                      inactive: _inactive,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final bool isHovered;
  final Color accent;
  final Color pillBg;
  final Color inactive;

  const _NavBarItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isHovered,
    required this.accent,
    required this.pillBg,
    required this.inactive,
  });

  @override
  Widget build(BuildContext context) {
    final hoverScale = isHovered ? 1.18 : 1.0;
    final hoverLift = isHovered ? -0.15 : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(
        horizontal: isSelected ? 16 : 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: isSelected ? pillBg : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSlide(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            offset: Offset(0, hoverLift),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              scale: hoverScale,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: isSelected ? 1 : 0),
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return Icon(
                    item.icon,
                    color: Color.lerp(inactive, accent, value),
                    size: 24,
                  );
                },
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axis: Axis.horizontal,
                    child: child,
                  ),
                );
              },
              child: isSelected
                  ? Padding(
                      key: ValueKey(item.label),
                      padding: const EdgeInsets.only(left: 8, top: 14),
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
} 