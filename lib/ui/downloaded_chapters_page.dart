import "package:app/hooks/use_daos.hook.dart";
import "package:app/hooks/use_novel.hook.dart";
import "package:app/models/chapter.dart";
import "package:app/models/novel.dart";
import "package:app/resource/paginated_resource.dart";
import "package:app/resource/resource.dart";
import "package:app/resource/resource.hooks.dart";
import "package:app/ui/router.hooks.dart";
import "package:app/widgets/resource_builder.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

part "downloaded_chapters_page.hooks.dart";

class DownloadedChaptersPage extends HookWidget {
  DownloadedChaptersPage({
    Key key,
    @required this.novelSource,
    @required this.novelSlug,
  })  : assert(novelSource != null),
        assert(novelSlug != null),
        super(key: key);

  final String novelSource;

  final String novelSlug;

  @override
  Widget build(BuildContext context) {
    return _PageState.use(
      parent: this,
      child: Scaffold(
        appBar: AppBar(
          title: _Title(),
        ),
        body: _Body(),
      ),
    );
  }
}

class _PageState extends StatelessWidget {
  _PageState._({
    Key key,
    @required this.novel,
    @required this.chapters,
    @required this.child,
  })  : assert(novel != null),
        assert(chapters != null),
        assert(child != null),
        super(key: key);

  factory _PageState.use({
    Key key,
    @required DownloadedChaptersPage parent,
    @required Widget child,
  }) {
    final novel = useNovel(parent.novelSource, parent.novelSlug);
    final chapters = _useDownloadedChapters(parent.novelSource, parent.novelSlug);

    return _PageState._(
      key: key,
      novel: novel,
      chapters: chapters,
      child: child,
    );
  }

  final Resource<Novel> novel;

  final PaginatedResource<Chapter> chapters;

  final Widget child;

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
      loadingBuilder: (BuildContext context) {
        return const Text("Loading…");
      },
      doneBuilder: (BuildContext context, Novel novel) {
        return Text(novel.name);
      },
    );
  }
}

class _Body extends HookWidget {
  _Body({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageState = _usePageState();

    return ResourceBuilder(
      resource: pageState.chapters,
      doneBuilder: (BuildContext context, List<Chapter> chapters) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
          ),
          itemBuilder: (BuildContext context, int index) {
            return _ChapterListTile(chapter: chapters[index]);
          },
          itemCount: chapters.length,
        );
      },
    );
  }
}

class _ChapterListTile extends HookWidget {
  _ChapterListTile({
    Key key,
    this.chapter,
  })  : assert(chapter != null),
        super(key: key);

  final Chapter chapter;

  @override
  Widget build(BuildContext context) {
    final router = useRouter();

    return ListTile(
      onTap: () {
        router.push().reader(url: chapter.url);
      },
      title: Text(chapter.title),
    );
  }
}
