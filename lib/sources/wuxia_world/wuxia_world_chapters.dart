import "dart:async";
import "dart:convert";

import "package:app/http/http.dart";
import "package:app/models/chapter.dart";
import "package:app/sources/chapter_source.dart";
import "package:app/utils/html_decompiler.dart" as markdown;
import "package:app/utils/html_utils.dart" as utils;
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

  Uri parseUrl(Element anchor, [Uri source]) {
    if (anchor == null) {
      return null;
    }
    final href = anchor.attributes["href"];
    try {
      final url = Uri.parse(href);
      return source != null ? source.resolveUri(url) : url;
    } on FormatException {
      return null;
    }
  }

  Element heading(Document document, List<RegExp> matchers) {
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

  String title(Document document, {bool simple = true}) {
    // Any text that matches these regexes are kept, order preserved
    final regexes = [
      new RegExp(r"book ?\d+", caseSensitive: false),
      new RegExp(r"vol(?:ume)? ?\d+", caseSensitive: false),
      new RegExp(r"chapter ?\d+", caseSensitive: false),
    ];

    final title = heading(document, regexes)?.text?.trim();

    if (simple == false || title == null) {
      return title;
    }

    final result = regexes
        .map((regex) => regex.stringMatch(title))
        .where((e) => e != null)
        .join(" - ");

    // If we could not extract any information, just return the original title
    return result.isEmpty ? title : result;
  }

  Uri nextUrl(Document document, Uri source) {
    final anchors = document.querySelectorAll(".next a[href*=novel]");
    return anchors.isNotEmpty ? parseUrl(anchors.first, source) : null;
  }

  Uri prevUrl(Document document, Uri source) {
    final anchors = document.querySelectorAll(".prev a[href*=novel]");
    return anchors.isNotEmpty ? parseUrl(anchors.first, source) : null;
  }

  String novelSlug(Uri url) {
    final path = url.pathSegments;
    final index = path.indexOf("novel");
    // The novel slug is directly after the novel segment
    return index >= 0 && index < path.length ? path[index + 1] : null;
  }

  void cleanup(Document document, Element article) {
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

  void makeTitle(Document document, Element article) {
    final title = this.title(document, simple: false);

    Element hidden() {
      final href = new Uri(path: "dialog", queryParameters: {"content": title});
      final anchor = new Element.tag("a");
      anchor.text = "Tap here to reveal spoiler title";
      anchor.attributes["href"] = href.toString();

      final strong = new Element.tag("strong");
      strong.children.add(anchor);

      final paragraph = new Element.tag("p");
      paragraph.children.add(strong);
      return paragraph;
    }

    Element normal() {
      final strong = new Element.tag("strong");
      strong.text = title;

      final paragraph = new Element.tag("p");
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
    });

    // Add the chapter title to the start of the article
    final spoiler = document.querySelectorAll(".text-spoiler").isNotEmpty;
    article.nodes.insert(0, spoiler ? hidden() : normal());

    // Add the normal title to the end of the chapter
    if (spoiler) {
      article.nodes.add(normal());
    }
  }

  bool containsIgnoreNoise(String string, String substring) {
    final noise = new RegExp(r"[^a-z0-9]", caseSensitive: false);
    string = string.toLowerCase().replaceAll(noise, "");
    substring = substring.toLowerCase().replaceAll(noise, "");
    return string.contains(substring);
  }

  Chapter fromHtml(Uri source, String body) {
    final document = html.parse(body);

    final article = document.querySelector(".content .fr-view");
    cleanup(document, article);
    makeTitle(document, article);

    return new Chapter(
      slug: slugify(uri: source),
      url: source,
      previousUrl: prevUrl(document, source),
      nextUrl: nextUrl(document, source),
      title: title(document),
      content: markdown.decompile(article.innerHtml),
      createdAt: new DateTime.now(),
      novelSlug: novelSlug(source),
    );
  }
}
