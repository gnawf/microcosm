import "package:app/models/chapter.dart";
import "package:app/models/novel.dart";
import "package:app/providers/provider.hooks.dart";
import "package:app/resource/paginated_resource.dart";
import "package:app/resource/resource.dart";
import "package:app/resource/resource.hooks.dart";
import "package:app/ui/novel_header.dart";
import "package:app/ui/router.hooks.dart";
import "package:app/widgets/settings_icon_button.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

part "novel_page.hooks.dart";

class NovelPage extends HookWidget {
  const NovelPage({
    @required this.source,
    @required this.slug,
  })  : assert(source != null),
        assert(slug != null);

  final String source;

  final String slug;

  @override
  Widget build(BuildContext context) {
    final novel = useNovel(source, slug);

    return _PageState(
      novel: novel,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: null,
          title: _Title(),
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
    @required this.child,
    this.novel,
  }) : super(key: key);

  final Widget child;

  final Resource<Novel> novel;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class _Title extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final pageState = usePageState();
    final novel = pageState.novel;

    switch (novel.state) {
      case ResourceState.placeholder:
        return const SizedBox.shrink();
      case ResourceState.loading:
        return const Text("Loading");
      case ResourceState.done:
        return Text(novel.data?.name ?? "Unknown");
      case ResourceState.error:
        return const Text("Error");
    }

    throw UnsupportedError("Switch was not exhaustive");
  }
}

class _Body extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final pageState = usePageState();
    final novel = pageState.novel;

    switch (novel.state) {
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
          child: Text("${novel.error}"),
        );
    }

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: NovelHeader(novel.data),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          sliver: _ChapterList(),
        ),
      ],
    );
  }
}

class _ChapterList extends HookWidget {
  SliverChildDelegate _emptyDelegate() {
    return SliverChildListDelegate([]);
  }

  SliverChildDelegate _loadingDelegate() {
    return SliverChildListDelegate(const [
      Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 16.0,
          ),
          child: CircularProgressIndicator(),
        ),
      ),
    ]);
  }

  SliverChildDelegate _dataDelegate(PaginatedResource<Chapter> resource) {
    final chapters = resource.data;

    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return _ChapterListItem(chapter: chapters[index]);
      },
      childCount: chapters.length,
    );
  }

  SliverChildDelegate _errorDelegate(Object error) {
    return SliverChildListDelegate([
      Center(
        child: Text("$error"),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final state = usePageState();
    final novel = state.novel.data;
    final chapters = useChapters(novel);

    SliverChildDelegate delegate;

    switch (chapters.state) {
      case ResourceState.placeholder:
        delegate = _emptyDelegate();
        break;
      case ResourceState.loading:
        delegate = _loadingDelegate();
        break;
      case ResourceState.done:
        delegate = _dataDelegate(chapters);
        break;
      case ResourceState.error:
        delegate = _errorDelegate(chapters.error);
        break;
    }

    assert(delegate != null);

    return SliverList(
      delegate: delegate,
    );
  }
}

class _ChapterListItem extends HookWidget {
  const _ChapterListItem({
    Key key,
    this.chapter,
  }) : super(key: key);

  final Chapter chapter;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _useVisitChapter(chapter),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        child: Text(chapter.title),
      ),
    );
  }
}
