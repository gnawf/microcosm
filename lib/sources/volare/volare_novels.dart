import "dart:convert";

import "package:app/http/http.dart";
import "package:app/models/novel.dart";
import "package:app/sources/data.dart";
import "package:app/sources/novel_source.dart";
import "package:app/utils/html_decompiler.dart" as markdown;
import "package:app/utils/map.extensions.dart";
import "package:meta/meta.dart";

class VolareNovels extends NovelSource {
  @override
  Future<Data<Novel>> get({String slug, Map<String, dynamic> params}) async {
    final result = await search(query: slug, params: null);
    return Data(
      data: result.data?.length == 1 ? result.data[0] : null,
    );
  }

  @override
  Future<DataList<Novel>> list({Map<String, dynamic> params}) async {
    return search(query: "", params: params);
  }

  @override
  Future<DataList<Novel>> search({@required String query, Map<String, dynamic> params}) async {
    final url = Uri(
      scheme: "https",
      host: "www.volarenovels.com",
      pathSegments: const ["api", "novels", "search"],
    );
    final request = await httpClient.postUrl(url);
    final requestBody = jsonEncode({
      "title": query,
      "tags": [],
      "language": null,
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
      source: "volare-novels",
      synopsis: markdown.decompile(map["synopsis"]),
      posterImage: map["coverUrl"],
    );
  }
}
