part of "novel_page.dart";

_PageState _usePageState() {
  return useContext().findAncestorWidgetOfExactType<_PageState>();
}

GestureTapCallback _useVisitChapter(Chapter chapter) {
  final router = useRouter();

  return () {
    router.push().reader(url: chapter.url);
  };
}
