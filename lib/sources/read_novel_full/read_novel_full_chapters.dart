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
  const ReadNovelFullChapters(this.parser);

  final ReadNovelFullChapterParser parser;

  @override
  Future<Chapter> get({String slug, Uri url}) async {
    if (slug != null) {
      throw new UnsupportedError("Unable to query by slug");
    }
    final request = await httpClient.getUrl(url);
    final response = await request.close();
    final body = await response.transform(convert.utf8.decoder).join();
    try {
      return parser.fromHtml(url, body);
    } catch (error) {
      print(error);
      if (error is Error) {
        print(error.stackTrace);
      }
      rethrow;
    }
  }

  @override
  Future<List<Chapter>> list({String novelSlug}) async {
    return <Chapter>[];
  }
}

class ReadNovelFullChapterParser {
  const ReadNovelFullChapterParser();

  Uri prevUrl(Document document, Uri source) {
    final href = document.querySelector("a#prev_chap").attributes["href"];
    return href != null ? source.resolve(href) : null;
  }

  Uri nextUrl(Document document, Uri source) {
    final href = document.querySelector("a#next_chap").attributes["href"];
    return href != null ? source.resolve(href) : null;
  }

  String title(Document document) {
    return document.querySelector(".chr-title").text;
  }

  Chapter fromHtml(Uri source, String body) {
    final document = html.parse(body);
    final article = document.querySelector("#chr-content");

    utils.traverse(article, (node) {
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
    );
  }
}
