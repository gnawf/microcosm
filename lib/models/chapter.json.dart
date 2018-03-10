import "package:app/models/chapter.dart";
import "package:app/models/novel.dart";

Map<String, dynamic> toJson(Chapter chapter) {
  return {
    "slug": chapter.slug,
    "url": chapter.url?.toString(),
    "previousUrl": chapter.previousUrl?.toString(),
    "nextUrl": chapter.nextUrl?.toString(),
    "title": chapter.title,
    "content": chapter.content,
    "createdAt": chapter.createdAt?.toUtc()?.toIso8601String(),
    "readAt": chapter.readAt?.toUtc()?.toIso8601String(),
    "novelSlug": chapter.novelSlug,
    "novel": chapter.novel?.toJson(),
  };
}

Chapter fromJson(Map<String, dynamic> json) {
  final slug = json["slug"];
  final sourceUrl = json["url"];
  final previousUrl = json["previousUrl"];
  final nextUrl = json["nextUrl"];
  final title = json["title"];
  final content = json["content"];
  final createdAt = json["createdAt"];
  final readAt = json["readAt"];
  final novelSlug = json["novelSlug"];
  final novel = json["novel"];

  return new Chapter(
    slug: slug,
    url: sourceUrl == null ? null : Uri.parse(sourceUrl),
    previousUrl: previousUrl == null ? null : Uri.parse(previousUrl),
    nextUrl: nextUrl == null ? null : Uri.parse(nextUrl),
    title: title,
    content: content,
    createdAt: createdAt == null ? null : DateTime.parse(createdAt),
    readAt: readAt == null ? null : DateTime.parse(readAt),
    novelSlug: novelSlug,
    novel: novel == null ? null : new Novel.fromJson(novel),
  );
}
