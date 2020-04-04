import "package:app/models/novel.json.dart" as mapper;
import "package:meta/meta.dart";

@immutable
class Novel {
  static const type = "novel";
  static const columns = mapper.columns;

  const Novel({
    this.slug,
    this.name,
    this.source,
    this.synopsis,
    this.posterImage,
  });

  factory Novel.fromJson(Map<String, dynamic> json) => mapper.fromJson(json);

  final String slug;
  final String name;
  final String source;
  final String synopsis;
  final String posterImage;

  Novel copyWith({
    String slug,
    String name,
    String source,
    String synopsis,
    String posterImage,
  }) {
    return Novel(
      slug: this.slug ?? slug,
      name: this.name ?? name,
      source: this.source ?? source,
      synopsis: this.synopsis ?? synopsis,
      posterImage: this.posterImage ?? posterImage,
    );
  }

  Map<String, dynamic> toJson() => mapper.toJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Novel &&
          runtimeType == other.runtimeType &&
          slug == other.slug &&
          name == other.name &&
          source == other.source &&
          synopsis == other.synopsis &&
          posterImage == other.posterImage;

  @override
  int get hashCode => slug.hashCode ^ name.hashCode ^ source.hashCode ^ synopsis.hashCode ^ posterImage.hashCode;

  @override
  String toString() {
    return "Novel{"
        "slug: $slug,"
        "name: $name,"
        "source: $source,"
        "synopsis: $synopsis,"
        "posterImage: $posterImage"
        "}";
  }
}
