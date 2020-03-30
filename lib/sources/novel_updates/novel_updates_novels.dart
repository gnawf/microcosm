import "dart:async";
import "dart:convert";

import "package:app/http/http.dart";
import "package:app/models/novel.dart";
import "package:app/sources/novel_source.dart";
import "package:app/utils/html_decompiler.dart";
import "package:html/parser.dart" as html show parse;

class NovelUpdatesNovels implements NovelSource {
  @override
  Future<Novel> get({String slug}) async {
    final url = new Uri(
      scheme: "https",
      host: "www.novelupdates.com",
      pathSegments: ["series", slug],
    );

    final request = await httpClient.getUrl(url);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    final document = html.parse(body);

    final title = document.querySelector(".seriestitlenu");
    final posterImage = document.querySelector(".seriesimg > img[src]");
    final description = document.querySelector("#editdescription");

    return new Novel(
      slug: slug,
      name: title.text,
      source: "wuxiaworld",
      synopsis: description != null ? decompile(description.text) : null,
      posterImage: posterImage?.attributes["src"],
    );
  }

  @override
  Future<List<Novel>> list({
    int limit,
    int offset,
    Map<String, dynamic> extras,
  }) async {
    final url = new Uri(
      scheme: "https",
      host: "www.novelupdates.com",
      pathSegments: ["group", "wuxiaworld"],
    );

    final request = await httpClient.getUrl(url);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    final document = html.parse(body);
    final select = document.querySelector("select#grouplst");

    final series = <Novel>[];

    for (final option in select.querySelectorAll("option")) {
      // Safeguard against random links
      if (!option.attributes["value"].contains("/series/")) {
        continue;
      }

      final name = option.text.trim();
      final url = Uri.parse(option.attributes["value"]);
      final slug = url.pathSegments[1];
      final novel = await get(slug: slug);
      series.add(novel);

      // Add warning message in case something goes wrong
      if (novel.name != name) {
        print("Names do not match up; expected $name but got ${novel.name}");
      }
    }

    return series;
  }
}
