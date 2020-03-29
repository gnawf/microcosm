import "package:app/models/chapter.dart";
import "package:app/models/novel.dart";
import "package:app/providers/provider.hooks.dart";
import "package:app/resource/paginated_resource.dart";
import "package:app/resource/resource.hooks.dart";
import "package:flutter_hooks/flutter_hooks.dart";

PaginatedResource<Chapter> useChapters(Novel novel) {
  final chapterProvider = useChapterProvider();
  final source = chapterProvider.source(id: novel.source);
  final chapters = usePaginatedResource<Chapter>();

  useEffect(() {
    chapters.value = const PaginatedResource.loading(cursor: 0);

    source.list(novelSource: null, novelSlug: novel.slug).then((value) {
      chapters.value = PaginatedResource.data(value, cursor: 1);
    }).catchError((error) {
      chapters.value = PaginatedResource.error(error);
    });

    return () {};
  }, []);

  return chapters.value;
}
