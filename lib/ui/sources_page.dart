import "package:app/sources/source.dart";
import "package:app/sources/sources.dart";
import "package:app/ui/router.dart";
import "package:app/widgets/md_icons.dart";
import "package:app/widgets/search_icon_button.dart";
import "package:app/widgets/settings_icon_button.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

@immutable
class SourcesPage extends HookWidget {
  const SourcesPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        title: const Text("Browse"),
        centerTitle: false,
        actions: const <Widget>[
          const SearchIconButton(),
          const SettingsIconButton(),
        ],
      ),
      body: _PageBody(),
    );
  }
}

@immutable
class _PageBody extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final sources = useSources();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        vertical: 12.0,
      ),
      itemBuilder: (context, index) {
        return _Source(sources[index]);
      },
      itemCount: sources.length,
    );
  }
}

@immutable
class _Source extends HookWidget {
  const _Source(this.source);

  final Source source;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 4.0,
      ),
      child: Card(
        child: InkWell(
          onTap: () {
            Router.of(context).push().source(sourceId: source.id);
          },
          child: ListTile(
            title: Text(source.name),
            trailing: Icon(MDIcons.chevronRight),
          ),
        ),
      ),
    );
  }
}
