import "package:app/hooks/use_novels.hook.dart";
import "package:app/resource/resource.dart";
import "package:app/sources/source.dart";
import "package:app/sources/sources.dart";
import "package:app/ui/router.hooks.dart";
import "package:app/widgets/novel_sliver_grid.dart";
import "package:app/widgets/settings_icon_button.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

part "source_page.hooks.dart";

class SourcePage extends HookWidget {
  const SourcePage({
    Key key,
    @required this.sourceId,
  }) : super(key: key);

  final String sourceId;

  @override
  Widget build(BuildContext context) {
    final source = useSource(id: sourceId);

    return _PageState(
      source: source,
      child: Scaffold(
        appBar: AppBar(
          title: _AppBarTitle(),
          centerTitle: false,
          actions: const <Widget>[
            SettingsIconButton(),
          ],
        ),
        body: _Novels(),
      ),
    );
  }
}

class _PageState extends StatelessWidget {
  const _PageState({
    Key key,
    @required this.source,
    @required this.child,
  }) : super(key: key);

  final Source source;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class _AppBarTitle extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final state = _usePageState();
    final source = state.source;
    return Text(source.name);
  }
}

class _Novels extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final state = _usePageState();
    final source = state.source;
    final novels = useNovels(source);
    final onTapNovel = _useOnTapNovel();

    switch (novels.state) {
      case ResourceState.placeholder:
        return const SizedBox.shrink();
      case ResourceState.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case ResourceState.done:
        break;
      case ResourceState.error:
        return Center(
          child: Text("${novels.error}"),
        );
    }

    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 18.0,
          ),
          sliver: NovelSliverGrid(
            novels: novels,
            onTap: onTapNovel,
          ),
        ),
      ],
    );
  }
}
