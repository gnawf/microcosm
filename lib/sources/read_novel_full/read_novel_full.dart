import "package:app/sources/chapter_source.dart";
import "package:app/sources/novel_source.dart";
import "package:app/sources/read_novel_full/read_novel_full_chapters.dart";
import "package:app/sources/read_novel_full/read_novel_full_novels.dart";
import "package:app/sources/source.dart";

class ReadNovelFull extends Source {
  @override
  final String id = "read-novel-full";
  @override
  final String name = "Read Novel Full";
  @override
  final ChapterSource chapters = ReadNovelFullChapters();
  @override
  final NovelSource novels = ReadNovelFullNovels();
}
