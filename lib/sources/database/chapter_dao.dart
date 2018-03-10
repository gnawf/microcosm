import "dart:async";

import "package:app/models/chapter.dart";
import "package:app/persistence/persistence.dart";
import "package:app/sources/chapter_source.dart";
import "package:app/sources/database/novel_dao.dart";
import "package:meta/meta.dart";

@immutable
class ChapterDao implements ChapterSource {
  const ChapterDao(this._persistence, this._novelDao);

  final Persistence _persistence;

  final NovelDao _novelDao;

  @override
  Future<Chapter> get({String slug, Uri url}) async {
    slug ??= slugify(uri: url);

    final chapters = await _persistence.select(
      table: Chapter.type,
      where: {"slug": slug},
      limit: 1,
    );

    if (chapters.isEmpty) {
      return null;
    }

    final chapter = new Chapter.fromJson(chapters.single);
    final novel = await _novelDao.get(slug: chapter.novelSlug);
    return chapter.copyWith(novel: novel);
  }

  Future<Null> upsert(Chapter chapter) async {
    if (chapter == null) {
      return null;
    }

    // This creates a Map<String, dynamic> of the attributes
    final attributes = chapter.toJson()..remove("novel");

    // Save relation
    _novelDao.upsert(chapter.novel);

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
