import "package:flutter/material.dart";

typedef Widget PageBuilder(BuildContext context);

class FadeTransitionPageRoute extends PageRouteBuilder {
  FadeTransitionPageRoute({RouteSettings settings, WidgetBuilder builder})
      : super(
          settings: settings,
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            return new FadeTransition(
              opacity: new Tween(begin: 0.0, end: 1.0).animate(animation),
              child: new FadeTransition(
                opacity: new Tween(begin: 1.0, end: 0.0).animate(secondaryAnimation),
                child: child,
              ),
            );
          },
          pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
            return builder(context);
          },
        );
}
