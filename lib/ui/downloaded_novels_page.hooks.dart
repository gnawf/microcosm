part of "downloaded_novels_page.dart";

PaginatedResource<Novel> _useDownloadedNovels() {
  final isDisposed = useIsDisposed();
  final novelDao = useNovelDao();
  final novels = usePaginatedResource<Novel>();

  useEffect(() {
    novels.value = const PaginatedResource.loading();

    () async {
      try {
        final value = await novelDao.withDownloads();
        if (isDisposed.value) {
          return;
        }
        novels.value = PaginatedResource.data(value);
      } on Error catch (e, s) {
        print(e);
        print(s);
        if (!isDisposed.value) {
          novels.value = PaginatedResource.error(e);
        }
      }
    }();

    return () {};
  }, []);

  return novels.value;
}
