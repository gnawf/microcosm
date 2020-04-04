import "package:flutter/material.dart";

typedef Widget PageBuilder(BuildContext context);

Widget _transitionsBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: Tween(begin: 0.0, end: 1.0).animate(animation),
    child: FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.0).animate(secondaryAnimation),
      child: child,
    ),
  );
}

class FadeTransitionPageRoute extends PageRouteBuilder {
  FadeTransitionPageRoute({RouteSettings settings, WidgetBuilder builder})
      : super(
          settings: settings,
          transitionsBuilder: _transitionsBuilder,
          pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
            return builder(context);
          },
        );
}
