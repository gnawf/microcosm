import "package:app/models/chapter.dart";
import "package:app/resource/paginated_resource.dart";
import "package:app/resource/resource.hooks.dart";
import "package:app/sources/sources.dart";
import "package:flutter_hooks/flutter_hooks.dart";

PaginatedResource<Chapter> useChapters(String novelSource, String novelSlug) {
  final source = getSource(id: novelSource)?.chapters;
  final chapters = usePaginatedResource<Chapter>();

  useEffect(() {
    // Do nothing if invalid input was provided
    if (source == null || novelSlug == null) {
      return () {};
    }

    chapters.value = const PaginatedResource.loading();

    source.list(novelSlug: novelSlug).then((value) {
      chapters.value = PaginatedResource.data(value.data);
    }).catchError((e, s) {
      chapters.value = PaginatedResource.error(e);
      print(e);
      print(s);
    });

    return () {};
  }, [source, novelSlug]);

  return chapters.value;
}
