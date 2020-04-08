part of "search_page.dart";

_PageState _usePageState() {
  final context = useContext();
  return context.findAncestorWidgetOfExactType<_PageState>();
}

VoidCallback _useOpenNovel(Novel novel) {
  final router = useRouter();

  return () {
    router.push().novel(novel: novel);
  };
}
