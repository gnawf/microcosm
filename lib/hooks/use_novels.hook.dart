import "package:app/hooks/use_daos.hook.dart";
import "package:app/models/novel.dart";
import "package:app/resource/paginated_resource.dart";
import "package:app/resource/resource.hooks.dart";
import "package:app/sources/source.dart";
import "package:flutter_hooks/flutter_hooks.dart";

PaginatedResource<Novel> useNovels(Source source) {
  final novels = usePaginatedResource<Novel>();
  final listParams = useState<Map<String, dynamic>>(const {});
  final dao = useNovelDao();

  useEffect(() {
    novels.value = const PaginatedResource.loading();

    Future<void> fetchData() async {
      List<Novel> newNovels;

      try {
        final prevData = novels.value.data ?? [];
        final newData = await source.novels.list(params: listParams.value);
        newNovels = newData.data;

        novels.value = PaginatedResource.data(
          [...prevData, ...newData.data],
          fetchMore: fetchData,
          hasMore: newData.data.isNotEmpty,
        );
        listParams.value = newData.extras;
      } catch (e, s) {
        novels.value = PaginatedResource.error(e);
        print(e);
        print(s);
      }

      if (newNovels != null) {
        newNovels.forEach(dao.upsert);
      }
    }

    fetchData();

    return () {};
  }, []);

  return novels.value;
}
