import "dart:async";
import "dart:convert" as convert;

import "package:app/http/http.dart";
import "package:app/models/chapter.dart";
import "package:app/sources/chapter_source.dart";
import "package:app/utils/html_decompiler.dart" as markdown;
import "package:app/utils/html_utils.dart" as utils;
import "package:html/dom.dart";
import "package:html/parser.dart" as html show parse;
import "package:meta/meta.dart";

@immutable
class ReadNovelFullChapters implements ChapterSource {
  @override
  Future<Chapter> get({String slug, Uri url}) async {
    if (slug != null) {
      throw new UnsupportedError("Unable to query by slug");
    }
    final request = await httpClient.getUrl(url);
    final response = await request.close();
    final body = await response.transform(convert.utf8.decoder).join();
    try {
      return _ChapterParser.fromHtml(url, body);
    } catch (error) {
      print(error);
      if (error is Error) {
        print(error.stackTrace);
      }
      rethrow;
    }
  }

  @override
  Future<List<Chapter>> list({String novelSource, String novelSlug}) async {
    return <Chapter>[];
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
    return title != null ? title.text : null;
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

    return new Chapter(
      slug: slugify(uri: source),
      url: source,
      previousUrl: prevUrl(document, source),
      nextUrl: nextUrl(document, source),
      title: title(document),
      content: markdown.decompile(article.innerHtml),
      createdAt: new DateTime.now(),
      novelSlug: source.pathSegments[0],
      novelSource: "read-novel-full",
    );
  }
}
