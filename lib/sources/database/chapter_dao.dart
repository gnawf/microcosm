import "dart:async";

import "package:app/database/database_wrapper.dart";
import "package:app/models/chapter.dart";
import "package:app/models/novel.dart";
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

    final chapters = await _database.rawQuery(
      """SELECT * FROM ${Chapter.type}
LEFT JOIN ${Novel.type} ON ${Novel.type}.slug=${Chapter.type}.novelSlug
WHERE ${Chapter.type}.slug = ?""",
      [slug],
    );

    return chapters.isNotEmpty ? _fromJoin(chapters.single) : null;
  }

  Future<List<Chapter>> list({
    @required String novelSlug,
    String orderBy,
    int limit,
    int offset,
  }) async {
    final chapters = await _database.query(
      table: Chapter.type,
      where: {"novelSlug": novelSlug},
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );

    return chapters.map(_fromJoin).toList();
  }

  Future<int> count({String novelSlug}) async {
    return await _database.count(
      table: Chapter.type,
      where: novelSlug != null ? {"novelSlug": novelSlug} : null,
    );
  }

  Future<List<Chapter>> recents({int limit = 20, int offset = 0}) async {
    final recents = await _database.rawQuery("""SELECT *, MAX(readAt)
FROM ${Chapter.type}
LEFT JOIN ${Novel.type} ON ${Novel.type}.slug=${Chapter.type}.novelSlug
WHERE readAt IS NOT NULL
GROUP BY novelSlug
ORDER BY readAt DESC
LIMIT $limit
OFFSET $offset""");

    return recents.map(_fromJoin).toList();
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

  Chapter _fromJoin(Map<String, dynamic> attributes) {
    final notAlphanumeric = new RegExp(r"[^\w]");
    final chapter = <String, dynamic>{};
    final novel = <String, dynamic>{};
    attributes.forEach((key, value) {
      // Ignore functions
      if (notAlphanumeric.hasMatch(key)) {
        return;
      }
      // Start populating the novel attributes once we hit the novel's slug
      // Assumption: the first column from chapter table is its slug
      if (novel.isNotEmpty || (chapter.isNotEmpty && key == "slug")) {
        novel[key] = value;
      } else {
        chapter[key] = value;
      }
    });
    return new Chapter.fromJson(chapter).copyWith(
      // Attach the novel object if present
      novel: novel["slug"] != null ? new Novel.fromJson(novel) : null,
    );
  }
}
