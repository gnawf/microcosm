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
    return _PageState.use(
      parent: this,
      child: Scaffold(
        appBar: AppBar(
          title: _Title(),
          centerTitle: false,
          actions: const [
            SettingsIconButton(),
          ],
        ),
        body: _Body(),
      ),
    );
  }
}

class _PageState extends StatelessWidget {
  const _PageState._({
    Key key,
    @required this.novel,
    @required this.chapters,
    @required this.child,
  })  : assert(novel != null),
        assert(chapters != null),
        assert(child != null),
        super(key: key);

  factory _PageState.use({Key key, @required NovelPage parent, @required Widget child}) {
    final novel = useNovel(parent.source, parent.slug);
    final chapters = useChapters(parent.source, parent.slug);

    return _PageState._(
      key: key,
      novel: novel,
      chapters: chapters,
      child: child,
    );
  }

  final Widget child;

  final Resource<Novel> novel;

  final PaginatedResource<Chapter> chapters;

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
      doneBuilder: (BuildContext context, Resource<Novel> novelResource) {
        final header = Padding(
          padding: const EdgeInsets.only(
            bottom: 8.0,
          ),
          child: NovelHeader(novelResource.data),
        );

        return ResourceBuilder(
          resource: pageState.chapters,
          loadingBuilder: (BuildContext context) {
            return ListView(
              children: [
                header,
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 24.0,
                    ),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            );
          },
          doneBuilder: (BuildContext context, PaginatedResource<Chapter> chaptersResource) {
            final chapters = chaptersResource.data;

            return ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return header;
                }
                return _ChapterListItem(chapter: chapters[index - 1]);
              },
              itemCount: 1 + chapters.length,
            );
          },
          emptyBuilder: (BuildContext context, PaginatedResource<Chapter> chaptersResource) {
            return ListView(
              children: [
                header,
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 24.0,
                    ),
                    child: Text("No chapters found"),
                  ),
                ),
              ],
            );
          },
        );
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
