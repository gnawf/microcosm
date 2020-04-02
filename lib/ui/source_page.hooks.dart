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

OnTapNovel _useOnTapNovel() {
  final router = useRouter();

  return (novel) {
    router.push().novel(novel: novel);
  };
}
