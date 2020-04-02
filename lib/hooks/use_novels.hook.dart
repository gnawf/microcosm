import "package:app/models/novel.dart";
import "package:app/resource/paginated_resource.dart";
import "package:app/resource/resource.hooks.dart";
import "package:app/sources/source.dart";
import "package:flutter_hooks/flutter_hooks.dart";

PaginatedResource<Novel> useNovels(Source source) {
  final novels = usePaginatedResource<Novel>();
  final params = useState<Map<String, dynamic>>(const {});

  useEffect(() {
    novels.value = const PaginatedResource.loading();

    Future<void> test() {
      return source.novels.list(params: params.value).then((value) {
        final prevData = novels.value.data ?? [];
        final newData = [...prevData, ...value.data];
        novels.value = PaginatedResource.data(
          newData,
          fetchMore: test,
          hasMore: value.data.isNotEmpty,
        );
        params.value = value.extras;
      }).catchError((error) {
        novels.value = PaginatedResource.error(error);
      });
    }

    test();

    return () {};
  }, []);

  return novels.value;
}
