import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

// ─── Shared count widget ──────────────────────────────────────────────────────

class _AnimatedCount extends StatelessWidget {
  const _AnimatedCount({required this.count, required this.style});

  final int count;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: Offset(0, child.key == ValueKey(count) ? 0.4 : -0.4),
          end: Offset.zero,
        ).animate(animation);
        return ClipRect(
          child: SlideTransition(
            position: slide,
            child: FadeTransition(opacity: animation, child: child),
          ),
        );
      },
      child: Text(_fmt(count), key: ValueKey(count), style: style),
    );
  }

  static String _fmt(int n) {
    if (n < 1000) return '$n';
    if (n < 1000000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '${(n / 1000000).toStringAsFixed(1)}M';
  }
}

// ─── Like Button ─────────────────────────────────────────────────────────────

/// Heart like button with scale pop, burst ring, and radial particles.
///
/// ```dart
/// LikeButton(
///   isLiked: post.isLiked,
///   likeCount: post.likesCount,
///   onTap: (_) => controller.toggleLike(post.id),
/// )
/// ```
class LikeButton extends StatefulWidget {
  const LikeButton({
    super.key,
    required this.isLiked,
    required this.onTap,
    this.likeCount = 0,
    this.size = 26,
    this.likedColor = AppColors.like,
    this.unlikedColor = Colors.black,
    this.showCount = true,
    this.axis = Axis.horizontal,
  });

  final bool isLiked;
  final int likeCount;
  final ValueChanged<bool> onTap;
  final double size;
  final Color likedColor;
  final Color unlikedColor;
  final bool showCount;
  /// [Axis.horizontal] puts count to the right; [Axis.vertical] puts it below.
  final Axis axis;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _particleProgress;
  late final Animation<Color?> _color;
  late final List<double> _particleAngles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.7)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.7, end: 1.35)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.35, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _ringScale = Tween<double>(begin: 0.0, end: 2.4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _ringOpacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _particleProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
    );

    _color = ColorTween(
      begin: widget.unlikedColor,
      end: widget.likedColor,
    ).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4)),
    );

    _particleAngles = List.generate(
      6,
      (i) => (i * (2 * math.pi / 6)) - math.pi / 2,
    );

    if (widget.isLiked) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiked != oldWidget.isLiked) {
      if (widget.isLiked) {
        _controller.forward(from: 0);
      } else {
        _controller.reverse(from: _controller.value.clamp(0.0, 1.0));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boxSize = widget.size * 2.2;

    return GestureDetector(
      onTap: () => widget.onTap(!widget.isLiked),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final iconBox = SizedBox(
            width: boxSize,
            height: boxSize,
            child: CustomPaint(
              painter: _LikeBurstPainter(
                ringScale: _ringScale.value,
                ringOpacity: _ringOpacity.value,
                particleProgress: _particleProgress.value,
                particleAngles: _particleAngles,
                color: widget.likedColor,
                iconSize: widget.size,
              ),
              child: Center(
                child: Transform.scale(
                  scale: _scale.value,
                  child: Icon(
                    widget.isLiked || _controller.value > 0.05
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: widget.size,
                    color: _color.value ?? widget.unlikedColor,
                  ),
                ),
              ),
            ),
          );

          if (!widget.showCount) return iconBox;

          final countWidget = _AnimatedCount(
            count: widget.likeCount,
            style: TextStyle(
              fontSize: widget.size * 0.45,
              fontWeight: FontWeight.w600,
              color: _color.value ?? widget.unlikedColor,
            ),
          );

          if (widget.axis == Axis.vertical) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: boxSize,
                  height: widget.size + 8,
                  child: OverflowBox(
                    alignment: Alignment.center,
                    maxWidth: boxSize,
                    maxHeight: boxSize,
                    child: iconBox,
                  ),
                ),
                countWidget,
              ],
            );
          }
          // Shift count left to remove the animation box dead space,
          // leaving ~4 px after the visible icon edge.
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconBox,
              Transform.translate(
                offset: Offset(-(widget.size * 0.6 - 4), 0),
                child: countWidget,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LikeBurstPainter extends CustomPainter {
  const _LikeBurstPainter({
    required this.ringScale,
    required this.ringOpacity,
    required this.particleProgress,
    required this.particleAngles,
    required this.color,
    required this.iconSize,
  });

  final double ringScale;
  final double ringOpacity;
  final double particleProgress;
  final List<double> particleAngles;
  final Color color;
  final double iconSize;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = iconSize * 0.55;

    if (ringOpacity > 0.01) {
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 * (1 - ringScale / 2.4).clamp(0.2, 1.0)
        ..color = color.withValues(alpha: ringOpacity);
      canvas.drawCircle(center, baseRadius * ringScale, ringPaint);
    }

    if (particleProgress > 0 && particleProgress < 1) {
      final travel = iconSize * 1.1;
      final fade = (1 - particleProgress).clamp(0.0, 1.0);
      final particlePaint = Paint()..color = color.withValues(alpha: fade);

      for (final angle in particleAngles) {
        final distance = travel * Curves.easeOut.transform(particleProgress);
        final dx = math.cos(angle) * distance;
        final dy = math.sin(angle) * distance;
        final radius = 2.5 * fade;
        if (radius > 0.1) {
          canvas.drawCircle(center + Offset(dx, dy), radius, particlePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LikeBurstPainter old) =>
      old.ringScale != ringScale ||
      old.ringOpacity != ringOpacity ||
      old.particleProgress != particleProgress;
}

// ─── Repost Button ────────────────────────────────────────────────────────────

/// Repost button with squash-pulse-settle animation and colorful confetti burst.
///
/// ```dart
/// RepostButton(
///   isReposted: post.isReposted,
///   repostCount: post.repostsCount,
///   onTap: (_) => controller.toggleRepost(post.id),
/// )
/// ```
class RepostButton extends StatefulWidget {
  const RepostButton({
    super.key,
    required this.isReposted,
    required this.onTap,
    this.repostCount = 0,
    this.size = 22,
    this.repostedColor = AppColors.repost,
    this.unrepostedColor = Colors.black87,
    this.showCount = true,
    this.axis = Axis.horizontal,
  });

  final bool isReposted;
  final int repostCount;
  final ValueChanged<bool> onTap;
  final double size;
  final Color repostedColor;
  final Color unrepostedColor;
  final bool showCount;
  /// [Axis.horizontal] puts count to the right; [Axis.vertical] puts it below.
  final Axis axis;

  @override
  State<RepostButton> createState() => _RepostButtonState();
}

class _RepostButtonState extends State<RepostButton>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _confettiProgress;
  late final Animation<Color?> _color;

  static const List<_RepostConfettiPiece> _pieces = [
    _RepostConfettiPiece(angleDeg: -45,  color: Color(0xFF00BA7C), distance: 1.1, shape: _ConfettiShape.square),
    _RepostConfettiPiece(angleDeg: -135, color: Color(0xFFFF9F2D), distance: 0.95, shape: _ConfettiShape.circle),
    _RepostConfettiPiece(angleDeg:  45,  color: Color(0xFF1D9BF0), distance: 1.0, shape: _ConfettiShape.square),
    _RepostConfettiPiece(angleDeg:  135, color: Color(0xFFF91880), distance: 1.05, shape: _ConfettiShape.circle),
    _RepostConfettiPiece(angleDeg: -90,  color: Color(0xFF00BA7C), distance: 1.2, shape: _ConfettiShape.square),
    _RepostConfettiPiece(angleDeg:   0,  color: Color(0xFFFFD400), distance: 1.0, shape: _ConfettiShape.circle),
    _RepostConfettiPiece(angleDeg:  180, color: Color(0xFF7856FF), distance: 1.0, shape: _ConfettiShape.square),
    _RepostConfettiPiece(angleDeg:   90, color: Color(0xFFFF6B6B), distance: 1.15, shape: _ConfettiShape.circle),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.85)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.85, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _confettiProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
    );

    _color = ColorTween(
      begin: widget.unrepostedColor,
      end: widget.repostedColor,
    ).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4)),
    );

    if (widget.isReposted) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant RepostButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isReposted != oldWidget.isReposted) {
      if (widget.isReposted) {
        _controller.forward(from: 0);
      } else {
        _controller.reverse(from: _controller.value.clamp(0.0, 1.0));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boxSize = widget.size * 2.6;

    return GestureDetector(
      onTap: () => widget.onTap(!widget.isReposted),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final iconBox = SizedBox(
            width: boxSize,
            height: boxSize,
            child: CustomPaint(
              painter: _RepostConfettiPainter(
                progress: _confettiProgress.value,
                pieces: _pieces,
                iconSize: widget.size,
              ),
              child: Center(
                child: Transform.scale(
                  scale: _scale.value,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _RepostIconPainter(
                      color: _color.value ?? widget.unrepostedColor,
                    ),
                  ),
                ),
              ),
            ),
          );

          if (!widget.showCount) return iconBox;

          final countWidget = _AnimatedCount(
            count: widget.repostCount,
            style: TextStyle(
              fontSize: widget.size * 0.5,
              fontWeight: FontWeight.w600,
              color: _color.value ?? widget.unrepostedColor,
            ),
          );

          if (widget.axis == Axis.vertical) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: boxSize,
                  height: widget.size + 8,
                  child: OverflowBox(
                    alignment: Alignment.center,
                    maxWidth: boxSize,
                    maxHeight: boxSize,
                    child: iconBox,
                  ),
                ),
                countWidget,
              ],
            );
          }
          // Horizontal: shift count left to remove animation box dead space.
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconBox,
              Transform.translate(
                offset: Offset(-(widget.size * 0.8 - 4), 0),
                child: countWidget,
              ),
            ],
          );
        },
      ),
    );
  }
}

enum _ConfettiShape { square, circle }

class _RepostConfettiPiece {
  const _RepostConfettiPiece({
    required this.angleDeg,
    required this.color,
    required this.distance,
    required this.shape,
  });
  final double angleDeg;
  final Color color;
  final double distance;
  final _ConfettiShape shape;
}

class _RepostConfettiPainter extends CustomPainter {
  const _RepostConfettiPainter({
    required this.progress,
    required this.pieces,
    required this.iconSize,
  });

  final double progress;
  final List<_RepostConfettiPiece> pieces;
  final double iconSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final center = Offset(size.width / 2, size.height / 2);
    final eased = Curves.easeOut.transform(progress);
    final fade = progress < 0.2
        ? progress / 0.2
        : (1 - (progress - 0.2) / 0.8).clamp(0.0, 1.0);

    for (final piece in pieces) {
      final angle = piece.angleDeg * math.pi / 180;
      final travel = iconSize * 1.3 * piece.distance * eased;
      final gravity = iconSize * 0.15 * eased * eased;
      final dx = math.cos(angle) * travel;
      final dy = math.sin(angle) * travel + gravity;
      final pos = center + Offset(dx, dy);
      final pieceSize = 3.0 * (1 - eased * 0.3);
      final paint = Paint()..color = piece.color.withValues(alpha: fade);

      if (piece.shape == _ConfettiShape.circle) {
        canvas.drawCircle(pos, pieceSize, paint);
      } else {
        canvas.save();
        canvas.translate(pos.dx, pos.dy);
        canvas.rotate(angle + eased * math.pi);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: pieceSize * 2, height: pieceSize * 2),
            const Radius.circular(0.8),
          ),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RepostConfettiPainter old) =>
      old.progress != progress;
}

class _RepostIconPainter extends CustomPainter {
  const _RepostIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final stroke = w * 0.11;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final topY = h * 0.30;
    final bottomY = h * 0.70;
    final leftX = w * 0.18;
    final rightX = w * 0.82;
    final arrowSize = w * 0.22;

    canvas.drawPath(
      Path()
        ..moveTo(leftX, topY + arrowSize * 0.9)
        ..lineTo(leftX, topY)
        ..lineTo(rightX - arrowSize * 0.2, topY),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(rightX - arrowSize, topY - arrowSize * 0.55)
        ..lineTo(rightX, topY)
        ..lineTo(rightX - arrowSize, topY + arrowSize * 0.55),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(rightX, bottomY - arrowSize * 0.9)
        ..lineTo(rightX, bottomY)
        ..lineTo(leftX + arrowSize * 0.2, bottomY),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(leftX + arrowSize, bottomY - arrowSize * 0.55)
        ..lineTo(leftX, bottomY)
        ..lineTo(leftX + arrowSize, bottomY + arrowSize * 0.55),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RepostIconPainter old) => old.color != color;
}

// ─── Follow Button ────────────────────────────────────────────────────────────

/// Animated follow button with check pop-in, label morph (Follow → Following),
/// and confetti burst when first followed.
///
/// Set [fillWidth] = true when placing inside an [Expanded].
///
/// ```dart
/// FollowButton(
///   isFollowing: user.isFollowing,
///   onTap: (following) => controller.toggleFollow(user.id, following),
///   fillWidth: true,
/// )
/// ```
class FollowButton extends StatefulWidget {
  const FollowButton({
    super.key,
    required this.isFollowing,
    required this.onTap,
    this.brandColor = AppColors.accent,
    this.followLabel = 'Follow',
    this.followingLabel = 'Following',
    this.height = 36.0,
    this.fillWidth = false,
    // Optional overrides for the "following" settled state.
    // Useful on dark backgrounds where theme defaults don't fit.
    this.unfollowedBorderColor,
    this.followedBgColor,
    this.followedFgColor,
    this.followedBorderColor,
  });

  final bool isFollowing;
  final ValueChanged<bool> onTap;
  final Color brandColor;
  final String followLabel;
  final String followingLabel;
  final double height;
  final bool fillWidth;
  final Color? unfollowedBorderColor;
  final Color? followedBgColor;
  final Color? followedFgColor;
  final Color? followedBorderColor;

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _buttonScale;
  late final Animation<double> _checkSlide;
  late final Animation<double> _confettiProgress;

  static const List<_FollowConfettiPiece> _pieces = [
    _FollowConfettiPiece(dx:  85, dy: -10, rotTurns:  0.55, color: Color(0xFF1D9BF0)),
    _FollowConfettiPiece(dx: -85, dy: -10, rotTurns: -0.55, color: Color(0xFFF91880)),
    _FollowConfettiPiece(dx:  70, dy: -45, rotTurns:  0.75, color: Color(0xFF00BA7C)),
    _FollowConfettiPiece(dx: -70, dy: -45, rotTurns: -0.75, color: Color(0xFFFFD400)),
    _FollowConfettiPiece(dx:  40, dy: -65, rotTurns:  1.00, color: Color(0xFFFF9F2D)),
    _FollowConfettiPiece(dx: -40, dy: -65, rotTurns: -1.00, color: Color(0xFF7856FF)),
    _FollowConfettiPiece(dx:   0, dy: -75, rotTurns:  0.50, color: Color(0xFFFF6B6B)),
    _FollowConfettiPiece(dx:  60, dy:  30, rotTurns:  0.33, color: Color(0xFF1D9BF0)),
    _FollowConfettiPiece(dx: -60, dy:  30, rotTurns: -0.33, color: Color(0xFFF91880)),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _buttonScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.92)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.92, end: 1.06)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.06, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 45,
      ),
    ]).animate(_controller);

    _checkSlide = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.55, curve: Curves.easeOutBack),
    );

    _confettiProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.05, 1.0, curve: Curves.easeOut),
    );

    if (widget.isFollowing) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant FollowButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFollowing != oldWidget.isFollowing) {
      if (widget.isFollowing) {
        _controller.forward(from: 0);
      } else {
        _controller.reverse(from: _controller.value.clamp(0.0, 1.0));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final bgColor = Color.lerp(
          widget.brandColor,
          widget.followedBgColor ?? Colors.transparent,
          t,
        )!;
        final fgColor = Color.lerp(
          Colors.white,
          widget.followedFgColor ?? Theme.of(context).colorScheme.onSurface,
          t,
        )!;
        final borderColor = Color.lerp(
          widget.unfollowedBorderColor ?? widget.brandColor,
          widget.followedBorderColor ?? Theme.of(context).colorScheme.outlineVariant,
          t,
        )!;

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Confetti overflows the button bounds.
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _FollowConfettiPainter(
                    progress: _confettiProgress.value,
                    pieces: _pieces,
                  ),
                ),
              ),
            ),
            Transform.scale(
              scale: _buttonScale.value,
              child: GestureDetector(
                onTap: () => widget.onTap(!widget.isFollowing),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: widget.height,
                  width: widget.fillWidth ? double.infinity : null,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: Border.all(color: borderColor, width: 1.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: widget.fillWidth
                        ? MainAxisSize.max
                        : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRect(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor: _checkSlide.value.clamp(0.0, 1.0),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Transform.scale(
                              scale: _checkSlide.value.clamp(0.0, 1.0),
                              child: Icon(Icons.check_rounded,
                                  size: 16, color: fgColor),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        widget.isFollowing
                            ? widget.followingLabel
                            : widget.followLabel,
                        style: TextStyle(
                          color: fgColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FollowConfettiPiece {
  const _FollowConfettiPiece({
    required this.dx,
    required this.dy,
    required this.rotTurns,
    required this.color,
  });
  final double dx;
  final double dy;
  final double rotTurns;
  final Color color;
}

class _FollowConfettiPainter extends CustomPainter {
  const _FollowConfettiPainter({required this.progress, required this.pieces});

  final double progress;
  final List<_FollowConfettiPiece> pieces;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final center = Offset(size.width / 2, size.height / 2);
    final eased = Curves.easeOut.transform(progress);
    final fade = progress < 0.15
        ? progress / 0.15
        : (1 - (progress - 0.15) / 0.85).clamp(0.0, 1.0);

    for (final p in pieces) {
      final pos = center + Offset(p.dx * eased, p.dy * eased);
      final pieceSize = 3.5 * (1 - eased * 0.4);
      final angle = p.rotTurns * 2 * math.pi * eased;
      final paint = Paint()..color = p.color.withValues(alpha: fade);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset.zero, width: pieceSize * 2, height: pieceSize * 2),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FollowConfettiPainter old) =>
      old.progress != progress;
}
