part of "download_chapters_page.dart";

Resource<Novel> useNovel(String source, String slug) {
  final novelProvider = useNovelProvider();
  final novel = useResource<Novel>();

  useEffect(() {
    novel.value = const Resource.loading();

    novelProvider.dao.get(source: source, slug: slug).then((value) {
      novel.value = Resource.data(value);
    }).catchError((error) {
      novel.value = Resource.error(error);
    });

    return () {};
  }, []);

  return novel.value;
}

_PageState _usePageState() {
  return useContext().findAncestorWidgetOfExactType<_PageState>();
}
