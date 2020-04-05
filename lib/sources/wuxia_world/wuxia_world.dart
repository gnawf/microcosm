import "package:app/sources/chapter_source.dart";
import "package:app/sources/novel_source.dart";
import "package:app/sources/source.dart";
import "package:app/sources/wuxia_world/wuxia_world_chapters.dart";
import "package:app/sources/wuxia_world/wuxia_world_novels.dart";

class WuxiaWorld extends Source {
  @override
  final String id = "wuxiaworld";
  @override
  final String name = "Wuxia World";
  @override
  final List<String> hosts = const [
    "wuxiaworld.com",
    "m.wuxiaworld.com",
    "www.wuxiaworld.com",
  ];
  @override
  final ChapterSource chapters = WuxiaWorldChapters();
  @override
  final NovelSource novels = WuxiaWorldNovels();
}
