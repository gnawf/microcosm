import "package:app/hooks/use_is_disposed.hook.dart";
import "package:app/models/chapter.dart";
import "package:app/resource/paginated_resource.dart";
import "package:app/resource/resource.hooks.dart";
import "package:app/sources/sources.dart";
import "package:flutter_hooks/flutter_hooks.dart";

PaginatedResource<Chapter> useChapters(String novelSource, String novelSlug) {
  final isDisposed = useIsDisposed();
  final source = getSource(id: novelSource)?.chapters;
  final chapters = usePaginatedResource<Chapter>();

  useEffect(() {
    // Do nothing if invalid input was provided
    if (source == null || novelSlug == null) {
      return () {};
    }

    chapters.value = const PaginatedResource.loading();

    () async {
      try {
        final result = await source.list(novelSlug: novelSlug);
        if (!isDisposed.value) {
          chapters.value = PaginatedResource.data(result.data);
        }
      } on Error catch (e, s) {
        print(e);
        print(s);
        if (!isDisposed.value) {
          chapters.value = PaginatedResource.error(e);
        }
      }
    }();

    return () {};
  }, [source, novelSlug]);

  return chapters.value;
}
