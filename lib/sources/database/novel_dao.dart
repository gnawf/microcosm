import "dart:async";

import "package:app/models/novel.dart";
import "package:app/persistence/persistence.dart";
import "package:app/sources/novel_source.dart";
import "package:meta/meta.dart";

@immutable
class NovelDao implements NovelSource {
  const NovelDao(this._persistence);

  final Persistence _persistence;

  @override
  Future<Novel> get({String slug}) async {
    final results = await _persistence.select(
      table: Novel.type,
      where: {"slug": slug},
      limit: 1,
    );

    return results.isEmpty ? null : new Novel.fromJson(results.single);
  }

  @override
  Future<List<Novel>> list({int limit, int offset}) async {
    final results = await _persistence.select(
      table: Novel.type,
      limit: limit,
      offset: offset,
    );

    return results.map((result) => new Novel.fromJson(result)).toList();
  }

  Future<Null> upsert(Novel novel) async {
    if (novel == null) {
      return;
    }

    // This creates a Map<String, dynamic> of the attributes
    final attributes = novel.toJson();

    final count = await _persistence.count(
      table: Novel.type,
      where: {"slug": novel.slug},
      limit: 1,
    );

    if (count == 1) {
      await _persistence.update(
        table: Novel.type,
        where: {"slug": novel.slug},
        attributes: attributes,
      );
    } else {
      await _persistence.insert(
        table: Novel.type,
        attributes: attributes,
      );
    }
  }
}
