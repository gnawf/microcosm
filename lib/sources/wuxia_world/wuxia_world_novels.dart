import "dart:convert";

import "package:app/http/http.dart";
import "package:app/models/novel.dart";
import "package:app/sources/data.dart";
import "package:app/sources/novel_source.dart";
import "package:app/utils/html_decompiler.dart" as markdown;
import "package:app/utils/map.extensions.dart";
import "package:app/utils/parsing.extensions.dart";
import "package:html/parser.dart" as html show parse;
import "package:meta/meta.dart";

class WuxiaWorldNovels extends NovelSource {
  @override
  Future<Data<Novel>> get({String slug, Map<String, dynamic> params}) async {
    final url = Uri.parse("https://www.wuxiaworld.com/novel/$slug");
    final request = await httpClient.getUrl(url);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    return Data(
      data: _NovelParser.parse(responseBody),
    );
  }

  @override
  Future<DataList<Novel>> list({Map<String, dynamic> params}) async {
    return search(query: "", params: params);
  }

  @override
  Future<DataList<Novel>> search({@required String query, Map<String, dynamic> params}) async {
    final url = Uri.parse("https://www.wuxiaworld.com/api/novels/search");
    final request = await httpClient.postUrl(url);
    final requestBody = jsonEncode({
      "title": query,
      "tags": [],
      "language": "Any",
      "genres": [],
      "active": null,
      "sortType": "Name",
      "sortAsc": true,
      "searchAfter": params?.get("cursor"),
      "count": params?.get("limit") ?? 10,
    });
    request.headers.set("Content-Type", "application/json; charset=utf-8");
    request.write(requestBody);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    final jsonResponseBody = jsonDecode(responseBody);

    return DataList(
      data: _SearchResultParser.parse(jsonResponseBody),
      extras: {
        "cursor": _SearchResultParser.getCursor(jsonResponseBody),
      },
    );
  }
}

class _NovelParser {
  static Novel parse(String body) {
    final document = html.parse(body);
    final scripts = document.query("script[type]");
    for (final script in scripts) {
      if (script.attributes["type"] != "application/ld+json") {
        continue;
      }
      if (script.text?.contains("\"@type\":\"Book\"") == true) {
        final decoded = jsonDecode(script.text);
        if (decoded is Map && decoded["@type"] == "Book") {
          final url = Uri.parse(decoded["url"]);
          final novelSegmentIndex = url.pathSegments.indexOf("novel");
          final slug = url.pathSegments[novelSegmentIndex + 1];
          return Novel(
            slug: slug,
            name: decoded["name"],
            source: "wuxiaworld",
            synopsis: markdown.decompile(decoded["description"]),
            posterImage: decoded["image"],
          );
        }
      }
    }
    return null;
  }
}

class _SearchResultParser {
  static List<Novel> parse(Object body) {
    if (body is Map) {
      final items = body["items"];
      if (items is List) {
        return items.map((e) => e is Map ? _parse(e) : null).toList();
      }
    }
    return [];
  }

  static Object getCursor(Object body) {
    if (body is Map) {
      final items = body["items"];
      if (items is List && items.isNotEmpty) {
        final last = items[items.length - 1];
        if (last is Map) {
          return last["id"];
        }
      }
    }
    return null;
  }

  static Novel _parse(Map map) {
    return Novel(
      slug: map["slug"],
      name: map["name"],
      source: "wuxiaworld",
      synopsis: markdown.decompile(map["synopsis"]),
      posterImage: map["coverUrl"],
    );
  }
}
