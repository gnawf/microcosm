part of "novel_page.dart";

Resource<Novel> useNovel(String source, String slug) {
  final novelProvider = useNovelProvider();
  final dao = novelProvider.dao;
  final novel = useResource<Novel>();

  useEffect(() {
    dao.get(source: source, slug: slug).then((value) {
      novel.value = Resource.data(value);
    }).catchError((error) {
      novel.value = Resource.error(error);
    });

    return () {};
  }, []);

  return novel.value;
}

_PageState usePageState() {
  return useContext().findAncestorWidgetOfExactType<_PageState>();
}

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

GestureTapCallback _useVisitChapter(Chapter chapter) {
  final context = useContext();

  return () {
    return Navigator.of(context).push(routes.reader(url: chapter.url));
  };
}
