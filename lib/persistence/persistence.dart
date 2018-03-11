import "dart:async";

import "package:app/models/chapter.dart";
import "package:app/models/novel.dart";
import "package:meta/meta.dart";
import "package:path/path.dart";
import "package:path_provider/path_provider.dart";
import "package:sqflite/sqflite.dart";
import "package:synchronized/synchronized.dart";

class Persistence {
  /// Do not use this directly, it may be null; instead use _open
  Database _database;

  Future<int> count({
    @required String table,
    Map where,
    String groupBy,
    String having,
    String orderBy,
    int limit,
    int offset,
  }) async {
    final db = await _open();
    final result = await db.query(
      table,
      columns: const <String>["COUNT(*)"],
      where: where?.keys?.map((key) => "$key = ?")?.join(","),
      whereArgs: where?.values?.toList(growable: false),
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    return Sqflite.firstIntValue(result);
  }

  Future<List<Map<String, dynamic>>> select({
    @required String table,
    Map where,
    String groupBy,
    String having,
    String orderBy,
    int limit,
    int offset,
  }) async {
    final db = await _open();
    return db.query(
      table,
      where: where?.keys?.map((key) => "$key = ?")?.join(","),
      whereArgs: where?.values?.toList(growable: false),
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// Returns the last inserted record id
  Future<int> insert({
    @required String table,
    @required Map attributes,
  }) async {
    final db = await _open();
    return db.insert(table, attributes);
  }

  /// Returns the number of changes made
  Future<int> update({
    @required String table,
    @required Map attributes,
    @required Map where,
  }) async {
    final db = await _open();
    return db.update(
      table,
      attributes,
      where: where.keys.map((key) => "$key = ?").join(","),
      whereArgs: attributes.values.toList(growable: false),
    );
  }

  /// Returns the number of changes made
  Future<int> delete({
    @required String table,
    @required Map where,
  }) async {
    final db = await _open();
    return db.delete(
      table,
      where: where.keys.map((key) => "$key = ?").join(","),
      whereArgs: where.values.toList(growable: false),
    );
  }

  Future<Database> _open() async {
    if (_database == null) {
      await synchronized(this, () async {
        // Double check pattern
        if (_database == null) {
          final documentsDirectory = await getApplicationDocumentsDirectory();
          final path = join(documentsDirectory.path, "microcosm.db");
          _database = await openDatabase(
            path,
            version: 4,
            onCreate: _onCreate,
            onUpgrade: _onUpgrade,
          );
        }
      });
    }
    return _database;
  }

  Future<Null> _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE IF NOT EXISTS ${Chapter.type} ("
        "slug TEXT PRIMARY KEY,"
        "url TEXT NOT NULL,"
        "previousUrl TEXT,"
        "nextUrl TEXT,"
        "title TEXT,"
        "content TEXT,"
        "createdAt TEXT,"
        "readAt TEXT,"
        "novelSlug TEXT"
        ")");

    await db.execute("CREATE TABLE IF NOT EXISTS ${Novel.type} ("
        "slug TEXT PRIMARY KEY,"
        "name TEXT NOT NULL,"
        "source TEXT,"
        "synopsis TEXT,"
        "posterImage TEXT"
        ")");
  }

  Future<Null> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Recreate the database
    await _onCreate(db, newVersion);

    if (oldVersion == 2) {
      await db.execute("ALTER TABLE ${Novel.type} ADD novelSlug TEXT");
      oldVersion++;
    }
    if (oldVersion == 3) {
      await db.execute("ALTER TABLE ${Chapter.type} ADD createdAt TEXT");
      await db.execute("ALTER TABLE ${Chapter.type} ADD readAt TEXT");
      oldVersion++;
    }
  }
}
