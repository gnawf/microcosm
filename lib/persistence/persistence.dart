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
    @required Map where,
    int limit,
  }) async {
    String sql = "SELECT COUNT(*) FROM $table "
        "WHERE "
        "${where.keys.map((key) => "$key = ?").join(",")}";
    if (limit != null) {
      sql += " LIMIT $limit";
    }
    final values = where.values.toList(growable: false);
    final db = await _open();
    final result = await db.rawQuery(sql, values);
    return Sqflite.firstIntValue(result);
  }

  Future<List<Map<String, dynamic>>> select({
    @required String table,
    Map where,
    int limit,
    int offset,
  }) async {
    String sql = "SELECT * FROM $table ";
    if (where != null) {
      sql += " WHERE ${where.keys.map((key) => "$key = ?").join(",")}";
    }
    if (limit != null) {
      sql += " LIMIT $limit";
    }
    if (offset != null) {
      sql += " OFFSET $offset";
    }

    final args = where != null ? where.values.toList(growable: false) : null;
    final db = await _open();
    return db.rawQuery(sql, args);
  }

  /// Returns the last inserted record id
  Future<int> insert({
    @required String table,
    @required Map attributes,
  }) async {
    final sql = "INSERT INTO $table("
        "${attributes.keys.join(",")}"
        ") VALUES ("
        "${attributes.values.map((value) => "?").join(",")}"
        ")";
    final values = attributes.values.toList(growable: false);
    final db = await _open();
    return db.rawInsert(sql, values);
  }

  /// Returns the number of changes made
  Future<int> update({
    @required String table,
    @required Map where,
    @required Map attributes,
  }) async {
    final sql = "UPDATE $table SET "
        "${attributes.keys.map((key) => "$key = ?").join(",")}"
        " WHERE "
        "${where.keys.map((key) => "$key = ?").join(",")}";
    final values = attributes.values.toList();
    values.addAll(where.values);
    final db = await _open();
    return db.rawUpdate(sql, values);
  }

  /// Returns the number of changes made
  Future<int> delete({
    @required String table,
    @required Map where,
  }) async {
    final sql = "DELETE FROM $table WHERE "
        "${where.keys.map((key) => "$key = ?").join(",")}";
    final values = where.values.toList(growable: false);
    final db = await _open();
    return db.rawUpdate(sql, values);
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
