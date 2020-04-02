import "package:html/dom.dart";

extension QueryDocument on Document {
  Element queryOne(String selector) => querySelector(selector);

  List<Element> query(String selector) => querySelectorAll(selector);
}

extension QueryElement on Element {
  Element queryOne(String selector) => querySelector(selector);

  List<Element> query(String selector) => querySelectorAll(selector);

  String attr(dynamic key) {
    final attrs = attributes;
    return attrs != null ? attrs[key] : null;
  }
}

extension ResolveUri on String {
  Uri resolveToUriFrom(Uri ref) => ref.resolve(this);
}
