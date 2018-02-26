import "package:app/widgets/md_icons.dart";
import "package:flutter/material.dart";

class AppBarUtils {
  static const double expandedAppBarHeight = 161.0;

  static Widget leading(BuildContext context) {
    // Nest the context so we can use the context to find the parent scaffold
    return new Builder(builder: (context) {
      final canPop = ModalRoute.of(context)?.canPop == true;
      // If we can go back, always prefer to
      // The default behavior prefers to show the menu over back
      return canPop
          ? const BackButton()
          : new IconButton(
              icon: const Icon(MDIcons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: "Open navigation menu",
            );
    });
  }

  static Widget darkOverlay() {
    return const DecoratedBox(
      decoration: const BoxDecoration(
        color: const Color.fromARGB(64, 0, 0, 0),
      ),
    );
  }

  static Widget darkGradientOverlay() {
    return const DecoratedBox(
      decoration: const BoxDecoration(
        gradient: const LinearGradient(
          begin: const Alignment(0.0, -1.0),
          end: const Alignment(0.0, -0.4),
          colors: const <Color>[
            const Color.fromARGB(64, 0, 0, 0),
            const Color.fromARGB(0, 0, 0, 0),
          ],
        ),
      ),
    );
  }
}
