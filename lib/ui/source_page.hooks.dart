part of "source_page.dart";

_PageState _usePageState() {
  return useContext().findAncestorWidgetOfExactType<_PageState>();
}

Resource<Source> _useSource(String id) {
  final source = useResource<Source>();
  final sources = useSources();

  useEffect(() {
    final value = sources.firstWhere((element) => element.id == id);
    source.value = value != null
        ? Resource.data(value)
        : const Resource.error("Source Not Found");
    return () {};
  }, []);

  return source.value;
}

PaginatedResource<Novel> useNovels(Source source) {
  final novelProvider = useNovelProvider();
  final dao = novelProvider.dao;
  final novels = usePaginatedResource<Novel>();

  useEffect(() {
    novels.value = const PaginatedResource.loading();

    dao.list(source: source.id).then((value) {
      novels.value = PaginatedResource.data(value, cursor: 0);
    }).catchError((error) {
      novels.value = PaginatedResource.error(error);
    });

    return () {};
  }, []);

  return novels.value;
}

OnTapNovel useOnTapNovel() {
  final router = useRouter();

  return (novel) {
    router.push().novel(novel: novel);
  };
}
