import "dart:async";

import "package:app/models/chapter.dart";
import "package:app/sources/data.dart";
import "package:meta/meta.dart";

abstract class ChapterSource {
  Future<Data<Chapter>> get({Uri url, Map<String, dynamic> params});

  Future<DataList<Chapter>> list({
    @required String novelSlug,
    Map<String, dynamic> params,
  });
}

typedef GetChapter = Future<Data<Chapter>> Function({
  Uri url,
  Map<String, dynamic> params,
});

typedef ListChapter = Future<DataList<Chapter>> Function({
  @required String novelSlug,
  Map<String, dynamic> params,
});
