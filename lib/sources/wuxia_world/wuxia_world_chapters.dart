import "dart:async";
import "dart:convert";

import "package:app/http/http.dart";
import "package:app/models/chapter.dart";
import "package:app/sources/chapter_source.dart";
import "package:app/sources/data.dart";
import "package:app/utils/html_decompiler.dart" as markdown;
import "package:app/utils/html_utils.dart" as utils;
import "package:app/utils/list.extensions.dart";
import "package:html/dom.dart";
import "package:html/parser.dart" as html show parse;
import "package:meta/meta.dart";

@immutable
class WuxiaWorldChapters implements ChapterSource {
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
      host: "wuxiaworld.com",
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
  static Element heading(Document document, List<RegExp> matchers) {
    final content = document.querySelector(".content");
    final headings = content.querySelectorAll("h1,h2,h3,h4,h5");

    if (headings.isEmpty) {
      return null;
    } else if (headings.length == 1) {
      return headings.single;
    }

    // Score each heading & determine which one is most likely the header
    var winner = 0;
    var hiscore = 0;
    for (var i = 0; i < headings.length; i++) {
      final heading = headings[i];
      final text = heading.text;

      var score = 0;

      // Award points per regex is matches
      for (final regex in matchers) {
        score += regex.hasMatch(text) ? 1 : 0;
      }

      // Award more points if it has the title icon next as a sibling
      final icon = heading.parent.querySelectorAll("img[src*=title-icon]");
      score += icon.isNotEmpty ? 2 : 0;

      if (score > hiscore) {
        winner = i;
        hiscore = score;
      }
    }

    return headings[winner];
  }

  static Element article(Document document) {
    final views = document.querySelectorAll(".content .fr-view");

    if (views.isEmpty) {
      return null;
    } else if (views.length == 1) {
      return views.single;
    }

    // Score each heading & determine which one is most likely the header
    var winner = 0;
    var hiscore = 0;
    for (var i = 0; i < views.length; i++) {
      final view = views[i];

      var score = 0;

      // Award more points if it has the title icon next as a sibling
      final icon = view.parent.querySelectorAll("img[src*=title-icon]");
      score += icon.isNotEmpty ? 2 : 0;

      if (score > hiscore) {
        winner = i;
        hiscore = score;
      }
    }

    return views[winner];
  }

  static String title(Document document, {bool simple = true}) {
    // Any text that matches these regexes are kept, order preserved
    final regexes = [
      RegExp(r"book ?\d+", caseSensitive: false),
      RegExp(r"vol(?:ume)? ?\d+", caseSensitive: false),
      RegExp(r"chapter ?\d+", caseSensitive: false),
    ];

    final title = heading(document, regexes)?.text?.trim();

    if (simple == false || title == null) {
      return title;
    }

    final result = regexes.map((regex) => regex.stringMatch(title)).where((e) => e != null).join(" - ");

    // If we could not extract any information, just return the original title
    return result.isEmpty ? title : result;
  }

  static Uri nextUrl(Document document, Uri source) {
    final anchors = document.querySelectorAll(".next a[href*=novel]");
    return anchors.isNotEmpty ? _Utils.parseUrl(anchors.first, source) : null;
  }

  static Uri prevUrl(Document document, Uri source) {
    final anchors = document.querySelectorAll(".prev a[href*=novel]");
    return anchors.isNotEmpty ? _Utils.parseUrl(anchors.first, source) : null;
  }

  static void cleanup(Document document, Element article) {
    article.querySelectorAll("p").forEach((p) {
      p.nodes.forEach((child) {
        if (child.nodeType == Node.TEXT_NODE) {
          final text = child.text.trim().toLowerCase();
          // This removes garbage from the chapter leftover from the old site
          if (text == "previous chapter" || text == "[/expand]") {
            // Clear the text to simulate removal
            // Avoid remove method due to concurrent access issues
            child.text = "";
          }
        }
      });
    });
    // Remove chapter navigation, sometimes they're tagged with this class
    article.querySelectorAll(".chapter-nav").forEach((e) => e.remove());
  }

  static void makeTitle(Document document, Element article) {
    final title = _ChapterParser.title(document, simple: false);

    Element hidden() {
      final href = Uri(path: "dialog", queryParameters: {"content": title});
      final anchor = Element.tag("a")
        ..text = "Tap here to reveal spoiler title"
        ..attributes["href"] = href.toString();

      final strong = Element.tag("strong");
      strong.children.add(anchor);

      final paragraph = Element.tag("p");
      paragraph.children.add(strong);
      return paragraph;
    }

    Element normal() {
      final strong = Element.tag("strong")..text = title;

      final paragraph = Element.tag("p");
      paragraph.children.add(strong);
      return paragraph;
    }

    // Remove any existing chapter titles
    utils.traverse(article, (node) {
      if (node.nodeType == Node.TEXT_NODE) {
        // Todo - strip the title itself instead of clearing it; this is a
        // precaution in case other text gets jumbled with the title text node
        if (containsIgnoreNoise(node.text, title)) {
          node.text = "";
        }
      }

      return true;
    });

    // Add the chapter title to the start of the article
    final spoiler = document.querySelectorAll(".text-spoiler").isNotEmpty;
    article.nodes.insert(0, spoiler ? hidden() : normal());

    // Add the normal title to the end of the chapter
    if (spoiler) {
      article.nodes.add(normal());
    }
  }

  static bool containsIgnoreNoise(String string, String substring) {
    final noise = RegExp(r"[^a-z0-9\s]", caseSensitive: false);
    string = string.toLowerCase().replaceAll(noise, "");
    substring = substring.toLowerCase().replaceAll(noise, "");
    // Allow extra words in the title
    substring = substring.replaceAll(RegExp(r"\s+"), r".+?");
    // Do contains check using the regular expression
    return RegExp(substring).hasMatch(string);
  }

  static Chapter fromHtml(Uri source, String body) {
    final document = html.parse(body);

    final article = _ChapterParser.article(document);
    cleanup(document, article);
    makeTitle(document, article);

    return Chapter(
      slug: slugify(uri: source),
      url: source,
      previousUrl: prevUrl(document, source),
      nextUrl: nextUrl(document, source),
      title: title(document),
      content: markdown.decompile(article.innerHtml),
      createdAt: DateTime.now(),
      novelSlug: _Utils.novelSlug(source),
      novelSource: "wuxiaworld",
    );
  }
}

@immutable
class _IndexParser {
  static List<Chapter> fromHtml(String body, Uri source) {
    final document = html.parse(body);

    final items = document.querySelectorAll("li.chapter-item");

    final novelSlug = _Utils.novelSlug(source);

    final chapters = items.map((item) {
      final anchor = item.querySelector("a[href*=novel]");
      final url = _Utils.parseUrl(anchor, source);

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
