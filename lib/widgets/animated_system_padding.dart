import "package:flutter/material.dart";

class AnimatedSystemPadding extends StatelessWidget {
  const AnimatedSystemPadding({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return new AnimatedContainer(
      padding: mediaQuery.viewInsets,
      curve: Curves.decelerate,
      duration: const Duration(milliseconds: 200),
      child: child,
    );
  }
}
