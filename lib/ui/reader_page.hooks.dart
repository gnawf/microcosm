part of "reader_page.dart";

_PageState _usePageState() {
  return useContext().findAncestorWidgetOfExactType<_PageState>();
}

VoidCallback _useOpenReader(Uri url) {
  final router = useRouter();
  return url != null ? () => router.pushReplacement().reader(url: url) : null;
}

VoidCallback _useOpenDownloadChapters() {
  final context = useContext();
  final state = _usePageState();
  final router = useRouter();
  final chapter = state.chapter.data;

  return () {
    if (chapter == null) {
      Scaffold.of(context).showMessageAsSnackBar("No chapter data");
      return;
    }

    final source = chapter.novelSource;
    final slug = chapter.novelSlug;
    router.push().downloadChapters(novelSource: source, novelSlug: slug, chapter: chapter);
  };
}

OverscrollNavigate _useChapterNavigation() {
  final pageState = _usePageState();
  final router = useRouter();
  final chapter = pageState.chapter.data;

  if (chapter == null) {
    return null;
  }

  return (axis) {
    switch (axis) {
      case AxisDirection.down:
        () async {
          await null;
          router.pushReplacement().reader(url: chapter.nextUrl);
        }();
        break;
      case AxisDirection.up:
      case AxisDirection.right:
      case AxisDirection.left:
        break;
    }
  };
}

MarkdownStyleSheet _useMarkdownStyleSheet() {
  final theme = useTheme();
  final settings = useSettings();
  final readerFontSize = settings.readerFontSize;
  final readerAlignment = settings.readerAlignment;

  final styleSheet = useState()..value ??= _createMarkdownStyleSheet(theme, readerFontSize, readerAlignment);

  // Cause re-render when dependencies change
  useListenable(settings.readerFontSizeChanges);
  useListenable(settings.readerAlignmentChanges);

  // Update stylesheet on future changes
  for (final dependency in [readerAlignment, readerFontSize, theme.textTheme.bodyText2.color]) {
    useValueChanged(dependency, (oldValue, oldResult) {
      styleSheet.value = _createMarkdownStyleSheet(theme, readerFontSize, readerAlignment);
    });
  }

  return styleSheet.value;
}

MarkdownStyleSheet _createMarkdownStyleSheet(ThemeData theme, double fontSize, WrapAlignment textAlign) {
  final defaults = theme.textTheme;
  final fontSizeScale = fontSize / defaults.bodyText2.fontSize;

  return MarkdownStyleSheet.fromTheme(
    theme.copyWith(
      textTheme: defaults.copyWith(
        bodyText1: defaults.bodyText1.copyWith(fontSize: defaults.bodyText1.fontSize * fontSizeScale),
        bodyText2: defaults.bodyText2.copyWith(fontSize: defaults.bodyText2.fontSize * fontSizeScale),
        headline5: defaults.headline5.copyWith(fontSize: defaults.headline5.fontSize * fontSizeScale),
        headline6: defaults.headline6.copyWith(fontSize: defaults.headline6.fontSize * fontSizeScale),
        subtitle1: defaults.subtitle1.copyWith(fontSize: defaults.subtitle1.fontSize * fontSizeScale),
      ),
    ),
  ).copyWith(
    textAlign: textAlign,
  );
}
