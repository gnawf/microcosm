import "dart:convert";

import "package:app/http/http.dart";
import "package:app/models/novel.dart";
import "package:app/sources/data.dart";
import "package:app/sources/novel_source.dart";
import "package:app/utils/list.extensions.dart";
import "package:app/utils/map.extensions.dart";
import "package:app/utils/parsing.extensions.dart";
import "package:html/dom.dart";
import "package:html/parser.dart" as html show parse;

class ReadNovelFullNovels extends NovelSource {
  @override
  Future<Data<Novel>> get({String slug, Map<String, dynamic> params}) async {
    final url = Uri.parse("https://readnovelfull.com/$slug.html");
    final request = await httpClient.getUrl(url);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    final location = response.redirects.tail()?.location ?? url;

    return Data(
      data: _NovelParser.fromHtml(slug, location, body),
    );
  }

  @override
  Future<DataList<Novel>> list({Map<String, dynamic> params}) async {
    final cursor = params.get("cursor") ?? 1;
    final url = Uri.parse(
      "https://readnovelfull.com/search?keyword=&page=$cursor",
    );
    final request = await httpClient.getUrl(url);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    final location = response.redirects.tail()?.location ?? url;

    return DataList(
      data: _SearchParser.fromHtml(location, body),
      extras: {
        "cursor": cursor + 1,
      },
    );
  }
}

class _NovelParser {
  static Novel fromHtml(String slug, Uri location, String body) {
    final document = html.parse(body);
    final name = _name(document) ?? slug;
    final synopsis = _synopsis(document);
    final posterImage = _posterImage(document);

    return Novel(
      slug: slug,
      name: name,
      source: "read-novel-full",
      synopsis: synopsis,
      posterImage: posterImage,
    );
  }

  static String _name(Document document) {
    return document.queryOne("h3.title")?.text;
  }

  static String _synopsis(Document document) {
    return document.queryOne("div.desc-text")?.text;
  }

  static String _posterImage(Document document) {
    final attrs = document.queryOne("div.book img[src]")?.attributes;
    return attrs != null ? attrs["src"] : null;
  }
}

class _SearchParser {
  static List<Novel> fromHtml(Uri location, String body) {
    final document = html.parse(body);
    final results = document.query(".col-novel-main .list-novel div.row");
    return results.map((result) => _fromNovel(result, location)).toList();
  }

  static Novel _fromNovel(Element result, Uri location) {
    return new Novel(
      slug: _slug(result, location),
      name: _name(result),
      source: "read-novel-full",
      synopsis: null,
      posterImage: _posterImage(result),
    );
  }

  static String _slug(Element result, Uri location) {
    final href = result.queryOne(".novel-title a[href]").attr("href");
    final uri = href.resolveToUriFrom(location);
    return uri.pathSegments[0].toSlug();
  }

  static String _name(Element result) {
    return result.queryOne(".novel-title")?.text;
  }

  static String _posterImage(Element result) {
    return result.queryOne("img.cover[src]")?.attr("src")?.toHighRes();
  }
}

extension _PathSegmentToSlug on String {
  static final _regex = new RegExp(
    "\/?(.*?)(\.html.*?)?\$",
    caseSensitive: false,
  );

  String toSlug() {
    return replaceAllMapped(_regex, (match) => match.group(1));
  }
}

extension _ToPosterImage on String {
  static final _regex = new RegExp(
    "\/t-\\d+x\\d+\/",
    caseSensitive: false,
  );

  String toHighRes() {
    return replaceAll(_regex, "/t-300x439/");
  }
}
