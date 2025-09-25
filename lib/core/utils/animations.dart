import 'package:flutter/material.dart';

class AppAnimations {
  // Fade in animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double beginOpacity = 0.0,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: beginOpacity, end: 1.0),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Slide in from bottom animation
  static Widget slideInUp({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    double beginOffset = 30.0,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: beginOffset, end: 0.0),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: child,
        );
      },
      child: child,
    );
  }

  // Slide in from left animation
  static Widget slideInLeft({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    double beginOffset = 30.0,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: beginOffset, end: 0.0),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  // Scale in animation
  static Widget scaleIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    double beginScale = 0.8,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: beginScale, end: 1.0),
      duration: duration,
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Staggered animation for lists
  static List<Widget> staggeredList({
    required List<Widget> children,
    Duration itemDuration = const Duration(milliseconds: 200),
    Duration initialDelay = const Duration(milliseconds: 100),
  }) {
    return children.asMap().entries.map((entry) {
      final child = entry.value;

      return TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: itemDuration,
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: child,
      );
    }).toList();
  }

  // Pulse animation for loading states
  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return _PulseAnimation(
      duration: duration,
      child: child,
    );
  }

  // Bounce in animation
  static Widget bounceIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.bounceOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _PulseAnimation extends StatefulWidget {
  const _PulseAnimation({
    required this.child,
    required this.duration,
  });

  final Widget child;
  final Duration duration;

  @override
  State<_PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0),
        weight: 50,
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      child: widget.child,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
    );
  }
}

// Animation constants
class AnimationConstants {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slower = Duration(milliseconds: 800);

  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
}

// Page transition animations
class PageTransitions {
  static SlideTransition slideFromRight({
    required Animation<double> animation,
    required Widget child,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }

  static SlideTransition slideFromLeft({
    required Animation<double> animation,
    required Widget child,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }

  static SlideTransition slideFromBottom({
    required Animation<double> animation,
    required Widget child,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }

  static FadeTransition fadeThrough({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
      child: child,
    );
  }
}
