import "package:app/providers/database_provider.dart";
import "package:app/providers/novel_provider.dart";
import "package:app/sources/chapter_source.dart";
import "package:app/sources/database/chapter_dao.dart";
import "package:app/sources/read_novel_full/read_novel_full_chapters.dart";
import "package:app/sources/volare/volare_chapters.dart";
import "package:app/sources/wuxia_world/wuxia_world_chapters.dart";
import "package:flutter/material.dart";
import "package:meta/meta.dart";

@deprecated
class ChapterProvider extends StatefulWidget {
  const ChapterProvider({@required this.child});

  final Widget child;

  static ChapterProviderState of(BuildContext context) {
    return context.findAncestorStateOfType<ChapterProviderState>();
  }

  @override
  State createState() => new ChapterProviderState();
}

class ChapterProviderState extends State<ChapterProvider> {
  final _wuxiaWorldChapters = WuxiaWorldChapters();

  final _volareChapters = VolareChapters();

  final _readNovelFullChapters = ReadNovelFullChapters();

  ChapterDao _chapterDao;

  ChapterDao get dao => _chapterDao;

  ChapterSource source({String id, Uri url}) {
    assert(id != null || url != null);

    if (id != null) {
      switch (id) {
        case "wuxiaworld":
          return _wuxiaWorldChapters;
        case "volare-novels":
          return _volareChapters;
        case "read-novel-full":
          return _readNovelFullChapters;
      }
    }

    if (url != null) {
      switch (url.host) {
        case "wuxiaworld.com":
        case "m.wuxiaworld.com":
        case "www.wuxiaworld.com":
          return _wuxiaWorldChapters;
        case "volarenovels.com":
        case "www.volarenovels.com":
          return _volareChapters;
        case "readnovelfull.com":
        case "www.readnovelfull.com":
          return _readNovelFullChapters;
      }
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
