import "package:app/ui/router.hooks.dart";
import "package:app/widgets/md_icons.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

class SettingsIconButton extends HookWidget {
  const SettingsIconButton();

  @override
  Widget build(BuildContext context) {
    final router = useRouter(rootNavigator: true);

    return IconButton(
      icon: const Icon(MDIcons.settings),
      tooltip: "Settings",
      onPressed: () => router.push().useCupertinoPageRoute().settings(),
    );
  }
}
