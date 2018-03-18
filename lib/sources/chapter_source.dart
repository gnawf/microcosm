import "dart:async";

import "package:app/models/chapter.dart";
import "package:meta/meta.dart";

abstract class ChapterSource {
  Future<Chapter> get({String slug, Uri url});

  Future<List<Chapter>> list({@required String novelSlug});
}
