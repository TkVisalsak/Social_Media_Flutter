import 'package:flutter/material.dart';

class CreateMenuItem {
  const CreateMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// A floating "+" button that rotates to an X and pops a menu sheet
/// above it. Each menu item slides in with a staggered delay.
class CreateFab extends StatefulWidget {
  const CreateFab({
    super.key,
    required this.items,
    this.brandColor = const Color(0xFF1D9BF0),
    this.menuWidth = 200,
  });

  final List<CreateMenuItem> items;
  final Color brandColor;
  final double menuWidth;

  @override
  State<CreateFab> createState() => _CreateFabState();
}

class _CreateFabState extends State<CreateFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _sheetScale;
  late final Animation<double> _sheetOpacity;
  late final Animation<double> _iconRotation;

  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 220),
    );

    _sheetScale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );

    _sheetOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6),
      reverseCurve: const Interval(0.4, 1.0),
    );

    // Plus rotates 45° to become an X.
    _iconRotation = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _close() {
    if (!_isOpen) return;
    setState(() => _isOpen = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        // Tap-outside scrim to dismiss. Only catches hits while open.
        if (_isOpen)
          Positioned(
            left: -2000,
            right: -2000,
            top: -2000,
            bottom: -80,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _close,
              child: const SizedBox.expand(),
            ),
          ),

        // The menu sheet, anchored above the FAB.
        Positioned(
          right: 0,
          bottom: 72, // FAB height (56) + gap (16)
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _sheetOpacity.value,
                child: Transform.scale(
                  scale: 0.5 + 0.5 * _sheetScale.value,
                  alignment: Alignment.bottomRight,
                  child: child,
                ),
              );
            },
            child: IgnorePointer(
              ignoring: !_isOpen,
              child: _MenuSheet(
                items: widget.items,
                width: widget.menuWidth,
                progress: _controller,
                onItemTap: (item) {
                  _close();
                  item.onTap();
                },
              ),
            ),
          ),
        ),

        // The FAB itself.
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: widget.brandColor,
          foregroundColor: Colors.white,
          elevation: 6,
          shape: const CircleBorder(),
          child: AnimatedBuilder(
            animation: _iconRotation,
            builder: (context, _) => Transform.rotate(
              angle: _iconRotation.value * 2 * 3.1415926,
              child: const Icon(Icons.add, size: 28),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuSheet extends StatelessWidget {
  const _MenuSheet({
    required this.items,
    required this.width,
    required this.progress,
    required this.onItemTap,
  });

  final List<CreateMenuItem> items;
  final double width;
  final Animation<double> progress;
  final ValueChanged<CreateMenuItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200, width: 0.5),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < items.length; i++)
              _StaggeredItem(
                index: i,
                total: items.length,
                progress: progress,
                child: _MenuRow(
                  item: items[i],
                  onTap: () => onItemTap(items[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StaggeredItem extends StatelessWidget {
  const _StaggeredItem({
    required this.index,
    required this.total,
    required this.progress,
    required this.child,
  });

  final int index;
  final int total;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = 0.25 + (index * 0.08);
    final end = (start + 0.45).clamp(0.0, 1.0);
    final anim = CurvedAnimation(
      parent: progress,
      curve: Interval(start, end, curve: Curves.easeOut),
    );

    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        return Opacity(
          opacity: anim.value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - anim.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.item, required this.onTap});

  final CreateMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(item.icon, size: 20, color: Colors.black87),
            const SizedBox(width: 12),
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
