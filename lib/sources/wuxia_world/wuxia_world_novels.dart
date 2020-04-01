import "dart:convert";

import "package:app/http/http.dart";
import "package:app/models/novel.dart";
import "package:app/sources/data.dart";
import "package:app/sources/novel_source.dart";

class WuxiaWorldNovels extends NovelSource {
  @override
  Future<Data<Novel>> get({String slug, Map<String, dynamic> params}) async {
    return Data(data: null);
  }

  @override
  Future<DataList<Novel>> list({Map<String, dynamic> params}) async {
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
      "searchAfter": params["cursor"],
      "count": params["limit"] ?? 10,
    });

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

  static String getCursor(Object body) {
    if (body is Map) {
      final items = body["items"];
      if (items is List) {
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
      source: "wuxia-world",
      synopsis: map["synopsis"],
      posterImage: map["coverUrl"],
    );
  }
}
