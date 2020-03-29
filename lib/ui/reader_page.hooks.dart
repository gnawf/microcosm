part of "reader_page.dart";

_PageState _usePageState() {
  return useContext().findAncestorWidgetOfExactType<_PageState>();
}

VoidCallback _useOpenReader(Uri url) {
  final router = useRouter();
  return url != null ? () => router.push().reader(url: url) : null;
}

VoidCallback _useOpenDownloadChapters() {
  final context = useContext();
  final state = _usePageState();
  final router = useRouter();
  final chapter = state.chapter;

  return () {
    if (chapter.data == null) {
      const snackBar = SnackBar(
        content: Text("No chapter data"),
      );
      Scaffold.of(context).showSnackBar(snackBar);
      return;
    }

    final source = chapter.data.novelSource;
    final slug = chapter.data.novelSlug;
    router.push().downloadChapters(novelSource: source, novelSlug: slug);
  };
}
