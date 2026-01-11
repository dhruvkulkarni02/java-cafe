import 'package:flutter/cupertino.dart';

class FadeScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeScalePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var curve = Curves.easeOutCubic;
            var tween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
            return ScaleTransition(
              scale: animation.drive(Tween(begin: 0.95, end: 1.0).chain(CurveTween(curve: curve))),
              child: FadeTransition(
                opacity: animation.drive(tween),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        );
}
