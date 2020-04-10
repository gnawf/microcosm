import "package:app/hooks/use_chapters.hook.dart";
import "package:app/hooks/use_novel.hook.dart";
import "package:app/models/chapter.dart";
import "package:app/models/novel.dart";
import "package:app/resource/paginated_resource.dart";
import "package:app/resource/resource.dart";
import "package:app/ui/novel_header.dart";
import "package:app/ui/router.hooks.dart";
import "package:app/widgets/resource_builder.dart";
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
    final pageState = _usePageState();

    return ResourceBuilder(
      resource: pageState.novel,
      loadingBuilder: _loadingBuilder,
      doneBuilder: _doneBuilder,
      errorBuilder: _errorBuilder,
    );
  }

  static Widget _loadingBuilder(BuildContext context) => const Text("Loading");

  static Widget _doneBuilder(BuildContext context, Resource<Novel> novel) => Text(novel.data?.name ?? "Unknown");

  static Widget _errorBuilder(BuildContext context, Resource<Novel> error) => const Text("Error");
}

class _Body extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final pageState = _usePageState();

    return ResourceBuilder(
      resource: pageState.novel,
      doneBuilder: _doneBuilder,
    );
  }

  static Widget _doneBuilder(BuildContext context, Resource<Novel> resource) {
    final novel = resource.data;

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: NovelHeader(novel),
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
  static SliverChildDelegate _emptyDelegate() {
    return SliverChildListDelegate(const []);
  }

  static SliverChildDelegate _dataDelegate(PaginatedResource<Chapter> resource) {
    final chapters = resource.data;

    return SliverChildBuilderDelegate(
      (BuildContext context, int index) => _ChapterListItem(chapter: chapters[index]),
      childCount: chapters.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _usePageState();
    final novel = state.novel.data;
    final chaptersResource = useChapters(novel.source, novel.slug);

    return ResourceBuilder(
      resource: state.novel,
      doneBuilder: (BuildContext context, Resource<Novel> novel) {
        final hasData = chaptersResource.data != null;
        final delegate = hasData ? _dataDelegate(chaptersResource) : _emptyDelegate();
        return SliverList(delegate: delegate);
      },
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
