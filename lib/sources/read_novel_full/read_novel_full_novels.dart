import "dart:convert";

import "package:app/http/http.dart";
import "package:app/models/novel.dart";
import "package:app/sources/data.dart";
import "package:app/sources/novel_source.dart";
import "package:html/dom.dart";
import "package:html/parser.dart" as html show parse;

class ReadNovelFullNovels extends NovelSource {
  @override
  Future<Data<Novel>> get({String slug, Map<String, dynamic> params}) async {
    final url = Uri.parse("https://readnovelfull.com/$slug.html");
    final request = await httpClient.getUrl(url);
    final response = await request.close();

    final body = await response.transform(utf8.decoder).join();

    final redirects = response.redirects;
    final source = redirects.isNotEmpty ? redirects.last.location : url;

    return Data(
      data: _NovelParser.fromHtml(slug, source, body),
    );
  }

  @override
  Future<DataList<Novel>> list({Map<String, dynamic> params}) async {
    return DataList(
      data: [],
    );
  }
}

class _NovelParser {
  static Novel fromHtml(String slug, Uri source, String body) {
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
    return document.querySelector("h3.title")?.text;
  }

  static String _synopsis(Document document) {
    return document.querySelector("div.desc-text")?.text;
  }

  static String _posterImage(Document document) {
    final attrs = document.querySelector("div.book img[src]")?.attributes;
    return attrs != null ? attrs["src"] : null;
  }
}
