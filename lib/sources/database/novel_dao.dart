import "dart:async";

import "package:app/database/database_wrapper.dart";
import "package:app/models/chapter.dart";
import "package:app/models/novel.dart";
import "package:meta/meta.dart";

@immutable
class NovelDao {
  const NovelDao(this._database);

  final DatabaseWrapper _database;

  Future<Novel> get({String source, String slug}) async {
    final results = await _database.query(
      table: Novel.type,
      where: {"source": source, "slug": slug},
      limit: 1,
    );

    return results.isEmpty ? null : Novel.fromJson(results.single);
  }

  Future<List<Novel>> list({
    String source,
    int limit,
    int offset,
  }) async {
    final results = await _database.query(
      table: Novel.type,
      limit: limit,
      offset: offset,
      where: {
        if (source != null) "source": source,
      },
    );

    return results.map((result) => Novel.fromJson(result)).toList();
  }

  Future<List<Novel>> withDownloads({int limit = 20, int offset = 0}) async {
    final results = await _database.rawQuery("""SELECT DISTINCT ${Novel.type}.*
FROM ${Novel.type}
INNER JOIN ${Chapter.type} ON
  ${Chapter.type}.novelSource=${Novel.type}.source
  AND ${Chapter.type}.novelSlug=${Novel.type}.slug
LIMIT $limit
OFFSET $offset""");

    return results.map((result) => Novel.fromJson(result)).toList();
  }

  Future<bool> exists({String slug}) async {
    final count = await _database.count(
      table: Novel.type,
      where: {"slug": slug},
      limit: 1,
    );
    return count > 0;
  }

  Future<void> upsert(Novel novel) async {
    if (novel == null) {
      return;
    }

    // This creates a Map<String, dynamic> of the attributes
    final attributes = novel.toJson();

    if (await exists(slug: novel.slug)) {
      await _database.update(
        table: Novel.type,
        where: {"slug": novel.slug},
        values: attributes,
      );
    } else {
      await _database.insert(
        table: Novel.type,
        values: attributes,
      );
    }
  }

  Future<void> purge() async {
    await _database.delete(table: Novel.type);
  }
}
