import "package:app/ui/routes.dart" as routes;
import "package:app/widgets/md_icons.dart";
import "package:flutter/material.dart";

class SettingsIconButton extends StatelessWidget {
  const SettingsIconButton();

  void _openSettings(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);
    final settings = routes.settings(type: routes.RouteType.slide);
    navigator.push(settings);
  }

  @override
  Widget build(BuildContext context) {
    return new IconButton(
      icon: const Icon(MDIcons.settings),
      onPressed: () => _openSettings(context),
    );
  }
}
