import "package:app/models/novel.dart";
import "package:app/providers/provider.hooks.dart";
import "package:app/resource/paginated_resource.dart";
import "package:app/resource/resource.dart";
import "package:app/resource/resource.hooks.dart";
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
    final source = _useSource(sourceId);

    return _PageState(
      source: source,
      child: new Scaffold(
        appBar: new AppBar(
          automaticallyImplyLeading: false,
          leading: null,
          title: _AppBarTitle(),
          centerTitle: false,
          actions: const <Widget>[
            const SettingsIconButton(),
          ],
        ),
        body: _Body(),
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

  final Resource<Source> source;

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

    switch (source.state) {
      case ResourceState.placeholder:
        return const Text("");
      case ResourceState.loading:
        return const Text("Loading");
      case ResourceState.done:
        return Text(source.data.name);
      case ResourceState.error:
        return const Text("Error");
    }

    throw UnsupportedError("Switch was not exhaustive");
  }
}

class _Body extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final state = _usePageState();
    final source = state.source;

    switch (source.state) {
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
          child: Text("${source.error}"),
        );
    }

    return _Novels(source.data);
  }
}

class _Novels extends HookWidget {
  const _Novels(this.source);

  final Source source;

  @override
  Widget build(BuildContext context) {
    final novels = useNovels(source);
    final onTapNovel = useOnTapNovel();

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
            novels: novels.data,
            onTap: onTapNovel,
          ),
        ),
      ],
    );
  }
}
