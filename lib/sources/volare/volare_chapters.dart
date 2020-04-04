import "dart:async";
import "dart:convert";

import "package:app/http/http.dart";
import "package:app/models/chapter.dart";
import "package:app/sources/chapter_source.dart";
import "package:app/sources/data.dart";
import "package:app/utils/html_decompiler.dart" as markdown;
import "package:app/utils/list.extensions.dart";
import "package:html/dom.dart";
import "package:html/parser.dart" as html show parse;

class VolareChapters implements ChapterSource {
  @override
  Future<Data<Chapter>> get({Uri url, Map<String, dynamic> params}) async {
    final request = await httpClient.getUrl(url);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    final location = response.redirects.tail()?.location ?? url;

    return Data(
      data: _ChapterParser.fromHtml(location, body),
    );
  }

  @override
  Future<DataList<Chapter>> list({
    String novelSlug,
    Map<String, dynamic> params,
  }) async {
    return DataList(data: null);
  }
}

class _ChapterParser {
  static String title(Document document) {
    final regexes = [
      RegExp(r"book ?\d+", caseSensitive: false),
      RegExp(r"vol(?:ume)? ?\d+", caseSensitive: false),
      RegExp(r"chapter ?\d+", caseSensitive: false),
    ];

    final title = document.querySelector(".entry-title")?.text?.trim();

    if (title == null) {
      return null;
    }

    final result = regexes.map((regex) => regex.stringMatch(title)).where((e) => e != null).join(" - ");

    return result.isEmpty ? title : result;
  }

  static Chapter fromHtml(Uri source, String body) {
    final document = html.parse(body);

    final content = document.querySelector(".entry-content");

    Uri previousUrl;
    Uri nextUrl;

    content.querySelectorAll("a[href*=volarenovels]").forEach((element) {
      final text = element.text.toLowerCase();
      final href = element.attributes["href"];
      final uri = source.resolve(href);

      if (text.contains("previous chapter")) {
        previousUrl = uri;
      }
      if (text.contains("next chapter")) {
        nextUrl = uri;
      }

      element.remove();
    });

    // Remove all the scripts
    content.querySelectorAll("script").forEach((e) => e.remove());

    return Chapter(
      slug: slugify(uri: source),
      url: source,
      previousUrl: previousUrl,
      nextUrl: nextUrl,
      title: title(document),
      content: markdown.decompile(content.innerHtml, source),
      createdAt: DateTime.now(),
      novelSlug: source.pathSegments.first,
      novelSource: "volare-novels",
    );
  }
}
