import "dart:async";

import "package:app/database/database_wrapper.dart";
import "package:app/models/chapter.dart";
import "package:app/sources/chapter_source.dart";
import "package:app/sources/database/novel_dao.dart";
import "package:meta/meta.dart";

@immutable
class ChapterDao implements ChapterSource {
  const ChapterDao(this._database, this._novelDao);

  final DatabaseWrapper _database;

  final NovelDao _novelDao;

  @override
  Future<Chapter> get({String slug, Uri url}) async {
    slug ??= slugify(uri: url);

    final chapters = await _database.query(
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

  Future<bool> exists({String slug, Uri url}) async {
    slug ??= slugify(uri: url);

    final count = await _database.count(
      table: Chapter.type,
      where: {"slug": slug},
      limit: 1,
    );
    return count > 0;
  }

  Future<Null> upsert(Chapter chapter) async {
    if (chapter == null) {
      return null;
    }

    // This creates a Map<String, dynamic> of the attributes
    final attributes = chapter.toJson()..remove("novel");

    // Save relation
    _novelDao.upsert(chapter.novel);

    if (await exists(slug: chapter.slug)) {
      // Don't overwrite createdAt attribute during update
      attributes.remove("createdAt");

      await _database.update(
        table: Chapter.type,
        values: attributes,
        where: {"slug": chapter.slug},
      );
    } else {
      await _database.insert(
        table: Chapter.type,
        values: attributes,
      );
    }
  }
}
