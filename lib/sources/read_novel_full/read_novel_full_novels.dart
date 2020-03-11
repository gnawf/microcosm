import "package:app/models/novel.dart";
import "package:app/sources/novel_source.dart";

class ReadNovelFullNovels extends NovelSource {
  @override
  Future<Novel> get({String slug}) async {
    return null;
  }

  @override
  Future<List<Novel>> list({int limit, int offset}) async {
    return [];
  }
}
