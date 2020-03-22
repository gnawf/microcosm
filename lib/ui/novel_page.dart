import "package:app/models/chapter.dart";
import "package:app/models/novel.dart";
import "package:app/ui/novel_header.dart";
import "package:app/ui/routes.dart" as routes;
import "package:app/widgets/list_chapters.dart";
import "package:app/widgets/novel_holder.dart";
import "package:flutter/material.dart";

class NovelPage extends StatelessWidget {
  const NovelPage({
    this.source,
    this.slug,
    this.novel,
  }) : assert((slug != null && source != null) || novel != null);

  final String source;

  final String slug;

  final Novel novel;

  @override
  Widget build(BuildContext context) {
    return new NovelHolder(
      source: source,
      slug: slug,
      novel: novel,
      builder: (BuildContext context, AsyncSnapshot<Novel> snapshot) {
        final novel = snapshot.data;

        return new Scaffold(
          appBar: new AppBar(
            automaticallyImplyLeading: false,
            leading: null,
            title: new Text(novel?.name ?? ""),
            centerTitle: false,
          ),
          body: new _NovelPageBody(novel),
        );
      },
    );
  }
}

class _NovelPageBody extends StatefulWidget {
  const _NovelPageBody(this.novel);

  final Novel novel;

  @override
  State createState() => new _NovelPageBodyState();
}

class _NovelPageBodyState extends State<_NovelPageBody> {
  @override
  Widget build(BuildContext context) {
    final novel = widget.novel;

    return new CustomScrollView(
      slivers: <Widget>[
        new SliverToBoxAdapter(
          child: new NovelHeader(novel),
        ),
        new SliverPadding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          sliver: new _ChapterList(novel.source, novel.slug),
        ),
      ],
    );
  }
}

class _ChapterList extends StatelessWidget {
  const _ChapterList(this.novelSource, this.novelSlug);

  final String novelSource;

  final String novelSlug;

  SliverChildDelegate _delegate(List<Chapter> chapters) {
    return new SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        final chapter = chapters[index];

        return new ListTile(
          onTap: () {
            Navigator.of(context).push(routes.reader(url: chapter.url));
          },
          title: new Text(chapter.title),
        );
      },
      childCount: chapters.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new ListChapters(
      novelSource: novelSource,
      novelSlug: novelSlug,
      builder: (BuildContext context, AsyncSnapshot<List<Chapter>> snapshot) {
        final chapters = snapshot.data;

        if (chapters?.isNotEmpty != true) {
          return const SliverToBoxAdapter(
            child: SizedBox.shrink(),
          );
        }

        return new SliverList(
          delegate: _delegate(chapters),
        );
      },
    );
  }
}
