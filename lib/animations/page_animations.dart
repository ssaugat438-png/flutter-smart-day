import 'package:flutter/material.dart';

/// Reusable animations and route transitions for SmartDay.
class PageAnimations {
  /// Builds a smooth Fade & Scale route transition.
  static Route<T> fadeScaleRoute<T>({required Widget page}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curve,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(curve),
            child: child,
          ),
        );
      },
    );
  }

  /// Builds a Slide-Up route transition for modal forms and sheets.
  static Route<T> slideUpRoute<T>({required Widget page}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.08);
        const end = Offset.zero;
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(begin: begin, end: end).animate(curve),
          child: FadeTransition(opacity: curve, child: child),
        );
      },
    );
  }
}

/// A wrapper widget that animates its child with a slight slide and fade on initial mount.
class AnimatedFadeSlide extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration duration;

  const AnimatedFadeSlide({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: duration.inMilliseconds + (index * 30)),
      curve: Curves.easeOutCubic,
      builder: (context, value, childWidget) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1.0 - value)),
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }
}
