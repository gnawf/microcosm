import "dart:async";

import "package:app/database/database_wrapper.dart";
import "package:app/models/chapter.dart";
import "package:app/models/novel.dart";
import "package:path/path.dart";
import "package:path_provider/path_provider.dart";
import "package:sqflite/sqflite.dart";

Future<DatabaseWrapper> newDatabase() async {
  final documents = await getApplicationDocumentsDirectory();
  final path = join(documents.path, "microcosm.db");
  final db = await openDatabase(
    path,
    version: 7,
    onCreate: _onCreate,
    onUpgrade: _onUpgrade,
  );
  return DatabaseWrapper(db);
}

Future<void> _onCreate(Database db, int version) async {
  await db.execute("""CREATE TABLE IF NOT EXISTS ${Chapter.type} (
        slug TEXT PRIMARY KEY,
        url TEXT NOT NULL,
        previousUrl TEXT,
        nextUrl TEXT,
        title TEXT,
        content TEXT,
        createdAt TEXT,
        readAt TEXT,
        novelSlug TEXT,
        novelSource TEXT
      )""");

  await db.execute("""CREATE TABLE IF NOT EXISTS ${Novel.type} (
          slug TEXT,
          name TEXT NOT NULL,
          source TEXT,
          synopsis TEXT,
          posterImage TEXT,
          PRIMARY KEY (source, slug)
        )""");
}

Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
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
  if (oldVersion == 4) {
    await db.execute("DROP TABLE ${Novel.type}");
    await db.execute("""CREATE TABLE ${Novel.type} (
        slug TEXT,
        name TEXT NOT NULL,
        source TEXT,
        synopsis TEXT,
        posterImage TEXT,
        PRIMARY KEY (source, slug)
        )""");
    oldVersion++;
  }
  if (oldVersion == 5) {
    await db.execute("ALTER TABLE ${Chapter.type} ADD novelSource TEXT");
    final chapters = await db.query(Chapter.type, columns: ["slug", "url"]);

    // Backfill source data based on the URL
    await db.transaction((txn) async {
      for (final chapter in chapters) {
        final slug = chapter["slug"];
        final url = chapter["url"];
        if (url is String) {
          String source;
          if (url.contains("wuxiaworld.com")) {
            source = "wuxiaworld";
          } else if (url.contains("volarenovels.com")) {
            source = "volare-novels";
          } else {
            continue;
          }
          await txn.update(Chapter.type, {"novelSource": source}, where: "slug = ?", whereArgs: [slug]);
        }
      }
    });

    oldVersion++;
  }
  if (oldVersion == 6) {
    await db.update(
      Chapter.type,
      {"novelSource": "read-novel-full"},
      where: "novelSource = ?",
      whereArgs: ["read-full-novel"],
    );

    oldVersion++;
  }
}
