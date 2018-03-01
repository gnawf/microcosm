import "dart:async";

import "package:app/models/chapter.dart";
import "package:app/persistence/persistence.dart";
import "package:app/sources/chapter_source.dart";
import "package:meta/meta.dart";

@immutable
class ChapterDao implements ChapterSource {
  const ChapterDao(this._persistence);

  final Persistence _persistence;

  @override
  Future<Chapter> get({String slug, Uri url}) async {
    slug ??= slugify(uri: url);

    final chapters = await _persistence.select(
      table: Chapter.type,
      where: {"slug": slug},
      limit: 1,
    );

    return chapters.isEmpty ? null : new Chapter.fromJson(chapters.single);
  }

  Future<Null> upsert(Chapter chapter) async {
    // This creates a Map<String, dynamic> of the attributes
    final attributes = chapter.toJson()..remove("novel");

    final count = await _persistence.count(
      table: Chapter.type,
      where: {"slug": chapter.slug},
      limit: 1,
    );

    if (count == 1) {
      await _persistence.update(
        table: Chapter.type,
        where: {"slug": chapter.slug},
        attributes: attributes,
      );
    } else {
      await _persistence.insert(
        table: Chapter.type,
        attributes: attributes,
      );
    }
  }
}
