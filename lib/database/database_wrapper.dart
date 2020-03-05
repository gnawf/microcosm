import "dart:async";

import "package:meta/meta.dart";
import "package:sqflite/sqflite.dart";

@immutable
class DatabaseWrapper {
  const DatabaseWrapper(this._database);

  final Database _database;

  String questions(int number) {
    switch (number) {
      case 0:
        return "";
      case 1:
        return "?";
      default:
        // Repeat the question mark number times then cut off trailing comma
        final questions = "?," * number;
        return questions.substring(0, questions.length - 1);
    }
  }

  String where(Map<String, dynamic> where) {
    if (where == null) {
      return null;
    }
    return where.entries.map((entry) {
      final key = entry.key;
      final value = entry.value;
      if (value is List) {
        return "$key IN (${questions(value.length)})";
      } else {
        return "$key = ?";
      }
    }).join(",");
  }

  List whereArgs(Map<String, dynamic> where) {
    if (where == null) {
      return null;
    }
    return where.entries
        .expand((entry) => entry.value is List ? entry.value : [entry.value])
        .toList(growable: false);
  }

  /// Counts the number of records for the given query
  /// See [Database.query]
  Future<int> count({
    @required String table,
    Map<String, dynamic> where,
    String groupBy,
    String having,
    String orderBy,
    int limit,
    int offset,
  }) async {
    final result = await _database.query(
      table,
      columns: const <String>["COUNT(*)"],
      where: this.where(where),
      whereArgs: whereArgs(where),
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    return Sqflite.firstIntValue(result);
  }

  /// See [Database.query]
  Future<List<Map<String, dynamic>>> query({
    @required String table,
    Map<String, dynamic> where,
    String groupBy,
    String having,
    String orderBy,
    int limit,
    int offset,
  }) async {
    return _database.query(
      table,
      where: this.where(where),
      whereArgs: whereArgs(where),
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// See [Database.rawQuery]
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List arguments]) {
    return _database.rawQuery(sql, arguments);
  }

  /// See [Database.insert]
  Future<int> insert({
    @required String table,
    @required Map values,
  }) async {
    return _database.insert(table, values);
  }

  /// See [Database.rawInsert]
  Future<int> rawInsert(String sql, [List arguments]) {
    return _database.rawInsert(sql, arguments);
  }

  /// See [Database.update]
  Future<int> update({
    @required String table,
    @required Map values,
    @required Map<String, dynamic> where,
  }) async {
    return _database.update(
      table,
      values,
      where: this.where(where),
      whereArgs: whereArgs(where),
    );
  }

  /// See [Database.rawUpdate]
  Future<int> rawUpdate(String sql, [List arguments]) {
    return _database.rawUpdate(sql, arguments);
  }

  /// See [Database.delete]
  Future<int> delete({
    @required String table,
    Map<String, dynamic> where,
  }) async {
    return _database.delete(
      table,
      where: this.where(where),
      whereArgs: whereArgs(where),
    );
  }

  /// See [Database.rawDelete]
  Future<int> rawDelete(String sql, [List arguments]) {
    return _database.rawUpdate(sql, arguments);
  }
}
