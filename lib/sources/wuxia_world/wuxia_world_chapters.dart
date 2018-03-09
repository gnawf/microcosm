import "dart:async";
import "dart:convert";

import "package:app/http/http.dart";
import "package:app/models/chapter.dart";
import "package:app/sources/chapter_source.dart";
import "package:app/utils/html_decompiler.dart";
import "package:html/dom.dart";
import "package:html/parser.dart" as html show parse;
import "package:meta/meta.dart";

@immutable
class WuxiaWorldChapters implements ChapterSource {
  const WuxiaWorldChapters(this.parser);

  final WuxiaWorldChapterParser parser;

  @override
  Future<Chapter> get({String slug, Uri url}) async {
    if (slug != null) {
      throw new UnsupportedError("Unable to query by slug");
    }
    final request = await httpClient.getUrl(url);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
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
}

class WuxiaWorldChapterParser {
  const WuxiaWorldChapterParser();

  Chapter fromHtml(Uri source, String body) {
    final document = html.parse(body);
    final article = document.querySelector("[itemprop=articleBody]");

    Uri previousUrl;
    Uri nextUrl;
    document.querySelectorAll("a[href*=chapter]").forEach((anchor) {
      final href = anchor.attributes["href"];
      final text = anchor.text.toLowerCase();

      if (text.contains("next")) {
        try {
          nextUrl = source.resolveUri(
            Uri.parse(href),
          );
          anchor.remove();
        } on FormatException catch (e) {
          print(e);
        }
      }
      if (text.contains("previous")) {
        try {
          previousUrl = source.resolveUri(
            Uri.parse(href),
          );
          anchor.remove();
        } on FormatException catch (e) {
          print(e);
        }
      }
    });

    document.querySelectorAll(".collapseomatic").forEach((collapsible) {
      final id = collapsible.attributes["id"];
      final target = document.querySelector("#target-$id");

      if (collapsible == null) {
        return;
      }

      target.remove();

      final content = target.text.trim();
      final href = "dialog?content=${Uri.encodeQueryComponent(content)}";
      final text = collapsible.text?.trim();
      final link = new Element.html('<a href="$href">$text</a>');
      collapsible.replaceWith(link);
    });

    document.querySelectorAll(".footnote > a").forEach((footnote) {
      final id = footnote.attributes["href"];
      final target = document.querySelector(id);
      target.querySelector(".footnotereverse").remove();

      final text = footnote.text;
      final content = decompile(target.innerHtml).trim();
      final href = "dialog?content=${Uri.encodeQueryComponent(content)}";

      final link = new Element.html('<a href="$href">$text</a>');
      footnote.parent.replaceWith(link);
    });

    return new Chapter(
      slug: slugify(uri: source),
      url: source,
      previousUrl: previousUrl,
      nextUrl: nextUrl,
      title: document
          .querySelector("title")
          .text
          .replaceAll("– Wuxiaworld", "")
          .trim(),
      content: decompile(article.innerHtml),
    );
  }
}
