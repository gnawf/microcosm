import "package:app/models/novel.dart";
import "package:app/sources/data.dart";
import "package:app/sources/novel_source.dart";

class VolareNovels extends NovelSource {
  @override
  Future<Data<Novel>> get({String slug, Map<String, dynamic> params}) async {
    return null;
  }

  @override
  Future<DataList<Novel>> list({Map<String, dynamic> params}) async {
    return DataList(
      data: [],
    );
  }
}
