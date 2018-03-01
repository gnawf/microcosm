import "dart:async";

import "package:app/models/novel.dart";

abstract class NovelSource {
  Future<Novel> get({String slug});

  Future<List<Novel>> list({int limit, int offset});
}
