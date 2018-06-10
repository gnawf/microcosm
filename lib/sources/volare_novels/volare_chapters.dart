import "dart:async";
import "dart:convert";

import "package:app/http/http.dart";
import "package:app/models/chapter.dart";
import "package:app/sources/chapter_source.dart";
import "package:app/utils/html_decompiler.dart" as markdown;
import "package:html/dom.dart";
import "package:html/parser.dart" as html show parse;
import "package:meta/meta.dart";

@immutable
class VolareChapters implements ChapterSource {
  const VolareChapters(this._chapterParser);

  final VolareChapterParser _chapterParser;

  @override
  Future<Chapter> get({String slug, Uri url}) async {
    final request = await httpClient.getUrl(url);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    // If present, follow the redirects to get the final URL
    final redirects = response.redirects;
    final source = redirects.isNotEmpty ? redirects.last.location : url;

    return _chapterParser.fromHtml(source, body);
  }

  @override
  Future<List<Chapter>> list({String novelSlug}) async {
    return <Chapter>[];
  }
}

@immutable
class VolareChapterParser {
  const VolareChapterParser();

  String title(Document document) {
    final regexes = [
      new RegExp(r"book ?\d+", caseSensitive: false),
      new RegExp(r"vol(?:ume)? ?\d+", caseSensitive: false),
      new RegExp(r"chapter ?\d+", caseSensitive: false),
    ];

    final title = document.querySelector(".entry-title")?.text?.trim();

    if (title == null) {
      return null;
    }

    final result = regexes
        .map((regex) => regex.stringMatch(title))
        .where((e) => e != null)
        .join(" - ");

    return result.isEmpty ? title : result;
  }

  Chapter fromHtml(Uri source, String body) {
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

    return new Chapter(
      slug: slugify(uri: source),
      url: source,
      previousUrl: previousUrl,
      nextUrl: nextUrl,
      title: title(document),
      content: markdown.decompile(content.innerHtml, source),
      createdAt: new DateTime.now(),
      novelSlug: source.pathSegments.first,
    );
  }
}
