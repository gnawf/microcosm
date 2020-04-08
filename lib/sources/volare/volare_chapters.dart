import "dart:async";
import "dart:convert";

import "package:app/http/http.dart";
import "package:app/models/chapter.dart";
import "package:app/sources/chapter_source.dart";
import "package:app/sources/data.dart";
import "package:app/utils/html_decompiler.dart" as markdown;
import "package:app/utils/list.extensions.dart";
import "package:app/utils/parsing.extensions.dart";
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
      data: await parseGet(location, body),
    );
  }

  @override
  Future<DataList<Chapter>> list({
    String novelSlug,
    Map<String, dynamic> params,
  }) async {
    final url = Uri(
      scheme: "https",
      host: "www.volarenovels.com",
      pathSegments: ["novel", novelSlug],
    );
    final request = await httpClient.getUrl(url);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    final location = response.redirects.tail()?.location ?? url;

    return DataList(
      data: _IndexParser.fromHtml(body, location),
    );
  }

  @override
  Future<Chapter> parseGet(Uri url, String html) async {
    return _ChapterParser.fromHtml(url, html);
  }
}

class _ChapterParser {
  static String title(Document document) {
    final regexes = [
      RegExp(r"book ?\d+", caseSensitive: false),
      RegExp(r"vol(?:ume)? ?\d+", caseSensitive: false),
      RegExp(r"chapter ?\d+", caseSensitive: false),
    ];

    final title = document.queryOne(".entry-title")?.text?.trim();

    if (title == null) {
      return null;
    }

    final result = regexes.map((regex) => regex.stringMatch(title)).where((e) => e != null).join(" - ");

    return result.isEmpty ? title : result;
  }

  static Chapter fromHtml(Uri source, String body) {
    final document = html.parse(body);

    final content = document.queryOne(".entry-content");

    Uri previousUrl;
    Uri nextUrl;

    content.query("a[href*=volarenovels]").forEach((element) {
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
    content.query("script").forEach((e) => e.remove());

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

class _IndexParser {
  static List<Chapter> fromHtml(String body, Uri location) {
    final document = html.parse(body);

    final items = document.querySelectorAll("li.chapter-item");

    final novelSlug = _Utils.novelSlug(location);

    final chapters = items.map((item) {
      final anchor = item.querySelector("a[href*=novel]");
      final url = _Utils.parseUrl(anchor, location);

      if (url == null) {
        return null;
      }

      return Chapter(
        slug: slugify(uri: url),
        url: url,
        title: item.text.trim(),
        novelSlug: novelSlug,
        novelSource: "wuxiaworld",
      );
    });

    return chapters.where((e) => e != null).toList(growable: false);
  }
}

class _Utils {
  static Uri parseUrl(Element anchor, [Uri source]) {
    if (anchor == null) {
      return null;
    }
    final href = anchor.attributes["href"];
    if (href == null) {
      return null;
    }
    try {
      final url = Uri.parse(href);
      return source != null ? source.resolveUri(url) : url;
    } on FormatException {
      return null;
    }
  }

  static String novelSlug(Uri url) {
    final path = url.pathSegments;
    final index = path.indexOf("novel");
    // The novel slug is directly after the novel segment
    return index >= 0 && index < path.length ? path[index + 1] : null;
  }
}
