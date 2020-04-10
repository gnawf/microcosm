part of "downloaded_chapters_page.dart";

_PageState _usePageState() {
  return useContext().findAncestorWidgetOfExactType();
}

PaginatedResource<Chapter> _useDownloadedChapters(String novelSource, String novelSlug) {
  final isDisposed = useIsDisposed();
  final chapterDao = useChapterDao();
  final chapters = usePaginatedResource<Chapter>();

  useEffect(() {
    chapters.value = const PaginatedResource.loading();

    () async {
      try {
        final value = await chapterDao.list(
          novelSource: novelSource,
          novelSlug: novelSlug,
          orderBy: "slug",
        );
        if (isDisposed.value) {
          return;
        }
        chapters.value = PaginatedResource.data(value);
      } on Error catch (e, s) {
        print(e);
        print(s);
        if (!isDisposed.value) {
          chapters.value = PaginatedResource.error(e);
        }
      }
    }();

    return () {};
  }, []);

  return chapters.value;
}
