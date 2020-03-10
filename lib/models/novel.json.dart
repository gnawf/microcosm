import "package:app/models/novel.dart";

const columns = [
  "slug",
  "name",
  "source",
  "synopsis",
  "posterImage",
];

Map<String, dynamic> toJson(Novel novel) {
  return {
    "slug": novel.slug,
    "name": novel.name,
    "source": novel.source,
    "synopsis": novel.synopsis,
    "posterImage": novel.posterImage,
  };
}

Novel fromJson(Map<String, dynamic> json) {
  final slug = json["slug"];
  final name = json["name"];
  final source = json["source"];
  final synopsis = json["synopsis"];
  final posterImage = json["posterImage"];

  return new Novel(
    slug: slug,
    name: name,
    source: source,
    synopsis: synopsis,
    posterImage: posterImage,
  );
}
