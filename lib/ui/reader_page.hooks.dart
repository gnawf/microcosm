part of "reader_page.dart";

Future<Chapter> fetch(Uri url, List<ChapterSource> sources) async {
  for (final source in sources) {
    try {
      final result = await source.get(url: url);
      if (result != null) {
        return result;
      }
    } catch (e, s) {
      print(e);
      print(s);
    }
  }

  return null;
}

Resource<Chapter> useChapter(Uri url) {
  final context = useContext();

  // State
  final currentLoadId = useState(0);
  final refreshRequest = useState<Completer>(null);
  final chapter = useResource<Chapter>();

  // Get sources
  final chapters = ChapterProvider.of(context);
  final dao = chapters.dao;
  final upstream = chapters.source(url: url);

  Future<void> getChapter([List<ChapterSource> sources]) async {
    sources ??= [dao, upstream];

    final loadId = ++currentLoadId.value;
    final value = await fetch(url, sources);
    if (loadId != currentLoadId.value) {
      return;
    }
    chapter.value = Resource.data(value, onRefresh: () {
      // Set the refresh request and then wait on its future
      return (refreshRequest.value = new Completer()).future;
    });
  }

  // Initial load
  useEffect(() {
    chapter.value = const Resource.loading();
    getChapter();
    return () {};
  }, [url]);

  // Fulfill refresh requests
  useEffect(() {
    final ourRefresh = refreshRequest.value;
    if (ourRefresh != null) {
      getChapter([upstream, dao]).then((value) => ourRefresh.complete());
    }
    return () {};
  }, [refreshRequest.value]);

  return chapter.value;
}

_PageState usePageState() {
  return useContext().findAncestorWidgetOfExactType<_PageState>();
}
