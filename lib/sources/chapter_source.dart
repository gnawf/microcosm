import "dart:async";

import "package:app/models/chapter.dart";

abstract class ChapterSource {
  Future<Chapter> get({String slug, Uri url});
}
