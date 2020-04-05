import "package:app/sources/chapter_source.dart";
import "package:app/sources/novel_source.dart";
import "package:app/sources/source.dart";
import "package:app/sources/volare/volare_chapters.dart";
import "package:app/sources/volare/volare_novels.dart";

class Volare extends Source {
  @override
  final String id = "volare-novels";
  @override
  final String name = "Volare Novels";
  @override
  final List<String> hosts = const [
    "volarenovels.com",
    "www.volarenovels.com",
  ];
  @override
  final ChapterSource chapters = VolareChapters();
  @override
  final NovelSource novels = VolareNovels();
}
