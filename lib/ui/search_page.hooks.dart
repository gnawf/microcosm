part of "search_page.dart";

typedef _Consumer<T> = dynamic Function(T t);

_PageState _usePageState() {
  final context = useContext();
  return context.findAncestorWidgetOfExactType<_PageState>();
}

void _useDebouncedSearch(String searchValue, _Consumer<String> search) {
  final lastSearchAt = useState<DateTime>();
  lastSearchAt.value ??= DateTime.now();

  useEffect(() {
    final now = DateTime.now();

    // Too much time elapsed since last search, do one now
    if (now.difference(lastSearchAt.value).inMilliseconds >= 1600) {
      lastSearchAt.value = now;
      search(searchValue);
      return () {};
    }

    // Otherwise, for a delay before inactivity then search
    const delay = Duration(milliseconds: 500);
    final timer = Timer(delay, () {
      lastSearchAt.value = now.add(delay);
      search(searchValue);
    });

    return () {
      // Cancel the timer once the search field changes
      timer.cancel();
    };
  }, [searchValue]);
}

VoidCallback _useOpenNovel(Novel novel) {
  final router = useRouter();

  return () {
    router.push().novel(novel: novel);
  };
}
