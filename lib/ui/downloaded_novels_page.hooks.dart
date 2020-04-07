part of "downloaded_novels_page.dart";

PaginatedResource<Novel> _useDownloadedNovels() {
  final novelDao = useNovelDao();
  final novels = usePaginatedResource<Novel>();

  useEffect(() {
    novels.value = const PaginatedResource.loading();

    () async {
      try {
        final value = await novelDao.withDownloads();
        novels.value = PaginatedResource.data(value);
      } on Error catch (e, s) {
        print(e);
        print(s);
        novels.value = PaginatedResource.error(e);
      }
    }();

    return () {};
  }, []);

  return novels.value;
}
