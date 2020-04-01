import "dart:async";

import "package:app/models/novel.dart";
import "package:app/sources/data.dart";

abstract class NovelSource {
  Future<Data<Novel>> get({String slug, Map<String, dynamic> params});

  Future<DataList<Novel>> list({Map<String, dynamic> params});
}

typedef GetNovel = Future<Data<Novel>> Function({
  String slug,
  Map<String, dynamic> params,
});

typedef ListNovels = Future<DataList<Novel>> Function({
  Map<String, dynamic> params,
});
