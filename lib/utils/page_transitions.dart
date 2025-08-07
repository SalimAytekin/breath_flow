import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';

/// 🎭 Professional Page Transitions
/// Custom page transitions matching Deep Night Serenity theme
class PageTransitions {
  /// 🌊 Slide Transition
  static PageRouteBuilder slideTransition({
    required Widget page,
    required RouteSettings settings,
    SlideDirection direction = SlideDirection.right,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        Offset begin;
        switch (direction) {
          case SlideDirection.right:
            begin = const Offset(1.0, 0.0);
            break;
          case SlideDirection.left:
            begin = const Offset(-1.0, 0.0);
            break;
          case SlideDirection.up:
            begin = const Offset(0.0, 1.0);
            break;
          case SlideDirection.down:
            begin = const Offset(0.0, -1.0);
            break;
        }
        
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween.chain(
          CurveTween(curve: AppSpacing.easeOutQuart),
        ));
        
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  /// 🌟 Fade Transition
  static PageRouteBuilder fadeTransition({
    required Widget page,
    required RouteSettings settings,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(
            CurveTween(curve: AppSpacing.easeOutQuart),
          ),
          child: child,
        );
      },
    );
  }

  /// 🎯 Scale Transition
  static PageRouteBuilder scaleTransition({
    required Widget page,
    required RouteSettings settings,
    Duration duration = const Duration(milliseconds: 300),
    double initialScale = 0.8,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = animation.drive(
          Tween(begin: initialScale, end: 1.0).chain(
            CurveTween(curve: AppSpacing.easeOutQuart),
          ),
        );
        
        final fadeAnimation = animation.drive(
          CurveTween(curve: AppSpacing.easeOutQuart),
        );
        
        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// 🌈 Rotation Transition
  static PageRouteBuilder rotationTransition({
    required Widget page,
    required RouteSettings settings,
    Duration duration = const Duration(milliseconds: 400),
    double turns = 0.15,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final rotationAnimation = animation.drive(
          Tween(begin: turns, end: 0.0).chain(
            CurveTween(curve: AppSpacing.easeOutQuart),
          ),
        );
        
        final scaleAnimation = animation.drive(
          Tween(begin: 0.8, end: 1.0).chain(
            CurveTween(curve: AppSpacing.easeOutQuart),
          ),
        );
        
        return RotationTransition(
          turns: rotationAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// 🎪 Shared Axis Transition
  static PageRouteBuilder sharedAxisTransition({
    required Widget page,
    required RouteSettings settings,
    SharedAxisTransitionType transitionType = SharedAxisTransitionType.horizontal,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: transitionType,
          child: child,
        );
      },
    );
  }

  /// 🌊 Fluid Transition
  static PageRouteBuilder fluidTransition({
    required Widget page,
    required RouteSettings settings,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _FluidTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }

  /// 🎨 Custom Transition Builder
  static PageRouteBuilder customTransition({
    required Widget page,
    required RouteSettings settings,
    required Widget Function(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) transitionsBuilder,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: transitionsBuilder,
    );
  }
}

/// 🎭 Shared Axis Transition Widget
class _SharedAxisTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final SharedAxisTransitionType transitionType;
  final Widget child;

  const _SharedAxisTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.transitionType,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        switch (transitionType) {
          case SharedAxisTransitionType.horizontal:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.3, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: AppSpacing.easeOutQuart,
              )),
              child: FadeTransition(
                opacity: animation,
                child: this.child,
              ),
            );
          
          case SharedAxisTransitionType.vertical:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: AppSpacing.easeOutQuart,
              )),
              child: FadeTransition(
                opacity: animation,
                child: this.child,
              ),
            );
          
          case SharedAxisTransitionType.scaled:
            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: AppSpacing.easeOutQuart,
              )),
              child: FadeTransition(
                opacity: animation,
                child: this.child,
              ),
            );
        }
      },
    );
  }
}

/// 🌊 Fluid Transition Widget
class _FluidTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const _FluidTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.25),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
        ));
        
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
        ));
        
        final scaleAnimation = Tween<double>(
          begin: 0.92,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
        ));
        
        return SlideTransition(
          position: slideAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: this.child,
            ),
          ),
        );
      },
    );
  }
}

/// 🎯 Navigation Helper
class NavigationHelper {
  /// Navigate with slide transition
  static Future<T?> slideToPage<T>(
    BuildContext context,
    Widget page, {
    SlideDirection direction = SlideDirection.right,
    bool replace = false,
  }) {
    final route = PageTransitions.slideTransition(
      page: page,
      settings: RouteSettings(name: page.runtimeType.toString()),
      direction: direction,
    );
    
    if (replace) {
      return Navigator.pushReplacement(context, route);
    } else {
      return Navigator.push(context, route);
    }
  }

  /// Navigate with fade transition
  static Future<T?> fadeToPage<T>(
    BuildContext context,
    Widget page, {
    bool replace = false,
  }) {
    final route = PageTransitions.fadeTransition(
      page: page,
      settings: RouteSettings(name: page.runtimeType.toString()),
    );
    
    if (replace) {
      return Navigator.pushReplacement(context, route);
    } else {
      return Navigator.push(context, route);
    }
  }

  /// Navigate with scale transition
  static Future<T?> scaleToPage<T>(
    BuildContext context,
    Widget page, {
    bool replace = false,
  }) {
    final route = PageTransitions.scaleTransition(
      page: page,
      settings: RouteSettings(name: page.runtimeType.toString()),
    );
    
    if (replace) {
      return Navigator.pushReplacement(context, route);
    } else {
      return Navigator.push(context, route);
    }
  }

  /// Navigate with fluid transition
  static Future<T?> fluidToPage<T>(
    BuildContext context,
    Widget page, {
    bool replace = false,
  }) {
    final route = PageTransitions.fluidTransition(
      page: page,
      settings: RouteSettings(name: page.runtimeType.toString()),
    );
    
    if (replace) {
      return Navigator.pushReplacement(context, route);
    } else {
      return Navigator.push(context, route);
    }
  }
}

/// 🎭 Enums
enum SlideDirection { right, left, up, down }

enum SharedAxisTransitionType { horizontal, vertical, scaled } 