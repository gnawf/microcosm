import "dart:async";
import "dart:convert" as convert;

import "package:app/http/http.dart";
import "package:app/models/chapter.dart";
import "package:app/sources/chapter_source.dart";
import "package:app/sources/data.dart";
import "package:app/utils/html_decompiler.dart" as markdown;
import "package:app/utils/html_utils.dart" as utils;
import "package:app/utils/list.extensions.dart";
import "package:app/utils/parsing.extensions.dart";
import "package:html/dom.dart";
import "package:html/parser.dart" as html show parse;
import "package:meta/meta.dart";

@immutable
class ReadNovelFullChapters implements ChapterSource {
  @override
  Future<Data<Chapter>> get({Uri url, Map<String, dynamic> params}) async {
    final request = await httpClient.getUrl(url);
    final response = await request.close();
    final body = await response.transform(convert.utf8.decoder).join();
    return Data(
      data: _ChapterParser.fromHtml(url, body),
    );
  }

  @override
  Future<DataList<Chapter>> list({
    String novelSlug,
    Map<String, dynamic> params,
  }) async {
    final novelId = await _getNovelId(novelSlug);
    final url = Uri(
      scheme: "https",
      host: "readnovelfull.com",
      pathSegments: ["ajax", "chapter-option"],
      queryParameters: {"novelId": "$novelId", "currentChapterId": ""},
    );
    final request = await httpClient.getUrl(url);
    final response = await request.close();
    final body = await response.transform(convert.utf8.decoder).join();

    final location = response.redirects.tail()?.location ?? url;

    return DataList(
      data: _ChapterListingParser.fromHtml(novelSlug, body, location),
    );
  }

  Future<int> _getNovelId(String novelSlug) async {
    final url = Uri.parse("https://readnovelfull.com/$novelSlug.html");
    final request = await httpClient.getUrl(url);
    final response = await request.close();
    final body = await response.transform(convert.utf8.decoder).join();
    return _NovelPageParser.getNovelId(body);
  }
}

class _ChapterParser {
  static Uri prevUrl(Document document, Uri source) {
    final button = document.querySelector("a#prev_chap");
    final href = button != null ? button.attributes["href"] : null;
    return href != null ? source.resolve(href) : null;
  }

  static Uri nextUrl(Document document, Uri source) {
    final button = document.querySelector("a#next_chap");
    final href = button != null ? button.attributes["href"] : null;
    return href != null ? source.resolve(href) : null;
  }

  static String title(Document document) {
    final title = document.querySelector(".chr-title");
    return title?.text;
  }

  static Chapter fromHtml(Uri source, String body) {
    final document = html.parse(body);
    final article = document.querySelector("#chr-content");

    utils.traverse(article, (node) {
      if (node.text.length > 20) {
        return true;
      }
      final text = node.text.toLowerCase();
      if (text == "previous chapter" || text == "next chapter") {
        node.text = "";
      }
      return true;
    });

    return Chapter(
      slug: slugify(uri: source),
      url: source,
      previousUrl: prevUrl(document, source),
      nextUrl: nextUrl(document, source),
      title: title(document),
      content: markdown.decompile(article.innerHtml),
      createdAt: DateTime.now(),
      novelSlug: source.pathSegments[0],
      novelSource: "read-novel-full",
    );
  }
}

class _NovelPageParser {
  static int getNovelId(String body) {
    final document = html.parse(body);
    const attrKey = "data-novel-id";
    final id = document.queryOne("#rating[$attrKey]")?.attr(attrKey);
    return int.tryParse(id);
  }
}

class _ChapterListingParser {
  static List<Chapter> fromHtml(String novelSlug, String body, Uri location) {
    final document = html.parse(body);
    final options = document.query("option[value]");
    return options.map((chapter) {
      final url = _url(chapter, location);
      return Chapter(
        slug: slugify(uri: url),
        url: url,
        previousUrl: null,
        nextUrl: null,
        title: _title(chapter),
        content: null,
        novelSlug: novelSlug,
        novelSource: "read-novel-full",
      );
    }).toList();
  }

  static Uri _url(Element chapter, Uri location) {
    return chapter.attr("value").resolveToUriFrom(location);
  }

  static String _title(Element chapter) {
    return chapter.text;
  }
}
