import "dart:convert";

import "package:app/http/http.dart";
import "package:app/models/novel.dart";
import "package:app/sources/novel_source.dart";

class WuxiaWorldNovels extends NovelSource {
  @override
  Future<Novel> get({String slug}) async {
    return null;
  }

  @override
  Future<List<Novel>> list({
    int limit,
    int offset,
    Map<String, dynamic> extras,
  }) async {
    final url = Uri.parse("https://www.wuxiaworld.com/api/novels/search");
    final request = await httpClient.postUrl(url);
    final requestBody = jsonEncode({
      "title": "",
      "tags": [],
      "language": "Any",
      "genres": [],
      "active": null,
      "sortType": "Name",
      "sortAsc": true,
      "searchAfter": offset,
      "count": limit,
    });
    request.write(requestBody);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    final jsonResponseBody = jsonDecode(responseBody);
    return _SearchResultParser.parse(jsonResponseBody);
  }
}

class _SearchResultParser {
  static List<Novel> parse(Object body) {
    if (body is Map) {
      final items = body["items"];
      if (items is List) {
        return items.map((e) {
          if (e is Map) {
            return Novel(
              slug: e["slug"],
              name: e["name"],
              source: "wuxia-world",
              synopsis: e["synopsis"],
              posterImage: e["coverUrl"],
            );
          }
          return null;
        }).toList(growable: false);
      }
    }
    return [];
  }
}
