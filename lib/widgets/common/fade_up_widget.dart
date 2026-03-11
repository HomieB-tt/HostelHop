import 'package:flutter/material.dart';

/// Fades and slides a child up on first build.
/// Drop-in wrapper for any screen body, section, or card that needs
/// a polished entrance without per-screen AnimationController boilerplate.
///
/// Usage:
///   FadeUpWidget(
///     delay: Duration(milliseconds: 120),
///     child: MyWidget(),
///   )
class FadeUpWidget extends StatefulWidget {
  const FadeUpWidget({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 380),
    this.offsetY = 0.06,
  });

  final Widget child;

  /// Delay before the animation starts — use for staggering multiple sections.
  final Duration delay;

  /// Total animation duration.
  final Duration duration;

  /// Vertical offset fraction to slide from (0.06 = 6% of widget height).
  final double offsetY;

  @override
  State<FadeUpWidget> createState() => _FadeUpWidgetState();
}

class _FadeUpWidgetState extends State<FadeUpWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.offsetY),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    if (widget.delay == Duration.zero) {
      _ctrl.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
