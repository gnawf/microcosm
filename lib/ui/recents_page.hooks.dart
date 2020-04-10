part of "recents_page.dart";

Future<Resource<List<Chapter>>> _fetchRecents(ChapterDao dao, ResourceRefresher refresher) async {
  try {
    return Resource.data(await dao.recents(), onRefresh: refresher);
  } on Error catch (e, s) {
    print(e);
    print(s);
    return Resource.error(e);
  }
}

_PageState _usePageState() {
  return useContext().findAncestorWidgetOfExactType<_PageState>();
}

Resource<List<Chapter>> _useRecents() {
  final isDisposed = useIsDisposed();
  final recents = useResource<List<Chapter>>();
  final dao = useChapterDao();

  useEffect(() {
    Future<void> execute() async {
      final result = await _fetchRecents(dao, execute);
      if (isDisposed.value) {
        return;
      }
      recents.value = result;
    }

    execute();

    return () {};
  }, []);

  return recents.value;
}

Resource<Chapter> _useChapter(Chapter chapter) {
  final resource = useResource<Chapter>();
  final novel = useNovel(chapter.novelSource, chapter.novelSlug);

  useEffect(() {
    resource.value = Resource.data(chapter.copyWith(novel: novel.data));
    return () {};
  }, [chapter, novel.state]);

  return resource.value;
}

VoidCallback _useOpenRecent(Chapter chapter) {
  final router = useRouter();

  return () {
    router.push().reader(url: chapter.url);
  };
}
