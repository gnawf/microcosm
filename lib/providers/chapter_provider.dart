import "package:app/providers/database_provider.dart";
import "package:app/providers/novel_provider.dart";
import "package:app/sources/chapter_source.dart";
import "package:app/sources/database/chapter_dao.dart";
import "package:app/sources/wuxia_world/wuxia_world_chapters.dart";
import "package:flutter/material.dart";
import "package:meta/meta.dart";

class ChapterProvider extends StatefulWidget {
  const ChapterProvider({@required this.child});

  final Widget child;

  static ChapterProviderState of(BuildContext context) {
    const matcher = const TypeMatcher<ChapterProviderState>();
    return context.ancestorStateOfType(matcher);
  }

  @override
  State createState() => new ChapterProviderState();
}

class ChapterProviderState extends State<ChapterProvider> {
  final _wuxiaWorldChapters = const WuxiaWorldChapters(
    const WuxiaWorldChapterParser(),
  );

  ChapterDao _chapterDao;

  ChapterDao get dao => _chapterDao;

  ChapterSource source(Uri url) {
    switch (url.host) {
      case "wuxiaworld.com":
      case "m.wuxiaworld.com":
      case "www.wuxiaworld.com":
        return _wuxiaWorldChapters;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    final databases = DatabaseProvider.of(context);
    final novels = NovelProvider.of(context);
    _chapterDao = new ChapterDao(databases.database, novels.dao);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
