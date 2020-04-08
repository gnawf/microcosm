import "package:app/hooks/use_daos.hook.dart";
import "package:app/hooks/use_debounced_value.dart";
import "package:app/hooks/use_novel.hook.dart";
import "package:app/models/chapter.dart";
import "package:app/models/novel.dart";
import "package:app/resource/paginated_resource.dart";
import "package:app/resource/resource.dart";
import "package:app/resource/resource.hooks.dart";
import "package:app/ui/router.hooks.dart";
import "package:app/widgets/resource_builder.dart";
import "package:app/widgets/settings_icon_button.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

part "downloaded_chapters_page.hooks.dart";

class DownloadedChaptersPage extends HookWidget {
  DownloadedChaptersPage({
    Key key,
    @required this.novelSource,
    @required this.novelSlug,
  })  : assert(novelSource != null),
        assert(novelSlug != null),
        super(key: key);

  final String novelSource;

  final String novelSlug;

  @override
  Widget build(BuildContext context) {
    return _PageState.use(
      parent: this,
      child: Scaffold(
        appBar: AppBar(
          title: _Title(),
          centerTitle: false,
          actions: const [
            SettingsIconButton(),
          ],
        ),
        body: _Body(),
      ),
    );
  }
}

class _PageState extends StatelessWidget {
  _PageState._({
    Key key,
    @required this.novel,
    @required this.chapters,
    @required this.chapterFilter,
    @required this.child,
  })  : assert(novel != null),
        assert(chapters != null),
        assert(child != null),
        super(key: key);

  factory _PageState.use({
    Key key,
    @required DownloadedChaptersPage parent,
    @required Widget child,
  }) {
    final novel = useNovel(parent.novelSource, parent.novelSlug);
    final chapters = _useDownloadedChapters(parent.novelSource, parent.novelSlug);
    final chapterFilter = useState("");

    return _PageState._(
      key: key,
      novel: novel,
      chapters: chapters,
      chapterFilter: chapterFilter,
      child: child,
    );
  }

  final Resource<Novel> novel;

  final PaginatedResource<Chapter> chapters;

  final ValueNotifier<String> chapterFilter;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class _Title extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final pageState = _usePageState();
    return ResourceBuilder(
      resource: pageState.novel,
      loadingBuilder: (BuildContext context) {
        return const Text("Loading…");
      },
      doneBuilder: (BuildContext context, Novel novel) {
        return Text(novel.name);
      },
    );
  }
}

class _Body extends HookWidget {
  _Body({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageState = _usePageState();

    return ResourceBuilder(
      resource: pageState.chapters,
      doneBuilder: (BuildContext context, List<Chapter> chapters) {
        return Column(
          children: <Widget>[
            _FilterField(),
            _ChapterList(chapters: chapters),
          ],
        );
      },
    );
  }
}

class _FilterField extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final pageState = _usePageState();
    final textController = useTextEditingController(text: pageState.chapterFilter.value);

    return Material(
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 24.0,
          horizontal: 16.0,
        ),
        child: TextField(
          controller: textController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Search",
          ),
          onChanged: (query) {
            pageState.chapterFilter.value = query;
          },
        ),
      ),
    );
  }
}

class _ChapterList extends HookWidget {
  _ChapterList({
    Key key,
    this.chapters,
  })  : assert(chapters != null),
        super(key: key);

  final List<Chapter> chapters;

  @override
  Widget build(BuildContext context) {
    final pageState = _usePageState();
    final filtered = useState(this.chapters);

    final filter = useState<Consumer<String>>()
      ..value ??= (string) async {
        filtered.value = this.chapters.where((chapter) => chapter.title.containsIgnoreCase(string)).toList();
      };

    // Debounce the filter function
    useDebouncedValue(value: pageState.chapterFilter.value, onTimeout: filter.value);

    // Auto update UI if chapters change
    useEffect(() {
      filtered.value = this.chapters;
      filter.value(pageState.chapterFilter.value);
      return () {};
    }, [this.chapters]);

    final chapters = filtered.value;

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          return _ChapterListTile(chapter: chapters[index]);
        },
        itemCount: chapters.length,
      ),
    );
  }
}

class _ChapterListTile extends HookWidget {
  _ChapterListTile({
    Key key,
    this.chapter,
  })  : assert(chapter != null),
        super(key: key);

  final Chapter chapter;

  @override
  Widget build(BuildContext context) {
    final router = useRouter();

    return ListTile(
      onTap: () {
        router.push().reader(url: chapter.url);
      },
      title: Text(chapter.title),
    );
  }
}

extension _ContainsIgnoreCase on String {
  bool containsIgnoreCase(String other) {
    return toLowerCase().contains(other.toLowerCase());
  }
}
