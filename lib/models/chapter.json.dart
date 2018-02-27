import "package:app/models/chapter.dart";

Map<String, dynamic> toJson(Chapter chapter) {
  return {
    "slug": chapter.slug,
    "url": chapter.url?.toString(),
    "previousUrl": chapter.previousUrl?.toString(),
    "nextUrl": chapter.nextUrl?.toString(),
    "title": chapter.title,
    "content": chapter.content,
  };
}

Chapter fromJson(Map<String, dynamic> json) {
  final slug = json["slug"];
  final sourceUrl = json["url"];
  final previousUrl = json["previousUrl"];
  final nextUrl = json["nextUrl"];
  final title = json["title"];
  final content = json["content"];

  return new Chapter(
    slug: slug,
    url: sourceUrl == null ? null : Uri.parse(sourceUrl),
    previousUrl: previousUrl == null ? null : Uri.parse(previousUrl),
    nextUrl: nextUrl == null ? null : Uri.parse(nextUrl),
    title: title,
    content: content,
  );
}
