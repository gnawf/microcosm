import "package:app/sources/chapter_source.dart";
import "package:app/sources/novel_source.dart";

abstract class Source {
  String get id;

  String get name;

  List<String> get hosts;

  ChapterSource get chapters;

  NovelSource get novels;
}
