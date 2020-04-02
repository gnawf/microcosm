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
    chapters.value = const PaginatedResource.loading();

    source.list(novelSlug: novel.slug).then((value) {
      chapters.value = PaginatedResource.data(value.data);
    }).catchError((e, s) {
      chapters.value = PaginatedResource.error(e);
      print(e);
      print(s);
    });

    return () {};
  }, []);

  return chapters.value;
}
