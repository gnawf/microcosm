import "package:app/ui/router.dart";
import "package:app/widgets/md_icons.dart";
import "package:flutter/material.dart";

class SettingsIconButton extends StatelessWidget {
  const SettingsIconButton();

  void _openSettings(BuildContext context) {
    Router.of(context, rootNavigator: true)
        .push()
        .useCupertinoPageRoute()
        .settings();
  }

  @override
  Widget build(BuildContext context) {
    return new IconButton(
      icon: const Icon(MDIcons.settings),
      tooltip: "Settings",
      onPressed: () => _openSettings(context),
    );
  }
}
