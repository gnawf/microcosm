part of "source_page.dart";

_PageState _usePageState() {
  return useContext().findAncestorWidgetOfExactType<_PageState>();
}

OnTapNovel _useOnTapNovel() {
  final router = useRouter();

  return (novel) {
    router.push().novel(novel: novel);
  };
}
