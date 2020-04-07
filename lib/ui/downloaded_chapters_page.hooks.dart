part of "downloaded_chapters_page.dart";

_PageState _usePageState() {
  return useContext().findAncestorWidgetOfExactType();
}

PaginatedResource<Chapter> _useDownloadedChapters(String novelSource, String novelSlug) {
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
        chapters.value = PaginatedResource.data(value);
      } on Error catch (e, s) {
        print(e);
        print(s);
        chapters.value = PaginatedResource.error(e);
      }
    }();

    return () {};
  }, []);

  return chapters.value;
}
