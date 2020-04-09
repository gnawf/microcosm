import "package:app/ui/router.hooks.dart";
import "package:app/widgets/md_icons.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

class SearchIconButton extends HookWidget {
  SearchIconButton({
    this.sourceId,
  });

  final String sourceId;

  @override
  Widget build(BuildContext context) {
    final router = useRouter();

    return IconButton(
      icon: const Icon(MDIcons.magnify),
      tooltip: "Search",
      onPressed: () => router.push().search(sourceId: sourceId),
    );
  }
}
