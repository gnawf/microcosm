import "package:app/hooks/use_chapters.hook.dart";
import "package:app/models/chapter.dart";
import "package:app/models/novel.dart";
import "package:app/providers/provider.hooks.dart";
import "package:app/resource/resource.dart";
import "package:app/resource/resource.hooks.dart";
import "package:app/widgets/settings_icon_button.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

part "download_chapters_page.hooks.dart";

typedef _IsSelected<T> = bool Function(T chapter);

typedef _SetSelected<T> = void Function(T chapter, bool value);

class DownloadChaptersPage extends HookWidget {
  const DownloadChaptersPage({
    Key key,
    @required this.novelSource,
    @required this.novelSlug,
  }) : super(key: key);

  final String novelSource;

  final String novelSlug;

  @override
  Widget build(BuildContext context) {
    final novel = useNovel(novelSource, novelSlug);
    final selected = useState(<String, Chapter>{});
    final hackInvalidate = useState(0);

    final isSelected = (Chapter chapter) {
      return selected.value[chapter.slug] != null;
    };

    final _SetSelected<Chapter> setSelected = (chapter, value) {
      selected.value = Map.from(selected.value)
        ..[chapter.slug] = value ? chapter : null;
      hackInvalidate.value++;
    };

    return _PageState(
      novel: novel,
      isSelected: isSelected,
      setSelected: setSelected,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: null,
          title: const Text("Download Chapters"),
          centerTitle: false,
          actions: const <Widget>[
            SettingsIconButton(),
          ],
        ),
        body: _Body(),
      ),
    );
  }
}

class _PageState extends StatelessWidget {
  const _PageState({
    Key key,
    @required this.child,
    @required this.novel,
    @required this.isSelected,
    @required this.setSelected,
  }) : super(key: key);

  final Widget child;

  final Resource<Novel> novel;

  final _IsSelected<Chapter> isSelected;

  final _SetSelected<Chapter> setSelected;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class _Body extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final state = _usePageState();
    final novel = state.novel;

    switch (novel.state) {
      case ResourceState.placeholder:
        return const SizedBox.shrink();
      case ResourceState.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case ResourceState.done:
        if (novel.data == null) {
          return const Center(
            child: Text("Unable to grab novel data"),
          );
        }
        break;
      case ResourceState.error:
        return Center(
          child: Text("${novel.error}"),
        );
    }

    return _SelectableList();
  }
}

class _SelectableList extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final state = _usePageState();
    final chapters = useChapters(state.novel.data);

    switch (chapters.state) {
      case ResourceState.placeholder:
        return const SizedBox.shrink();
      case ResourceState.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case ResourceState.done:
        break;
      case ResourceState.error:
        return Center(
          child: Text("${chapters.error}"),
        );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
      ),
      itemBuilder: (BuildContext context, int index) {
        final chapter = chapters.data[index];
        return _SelectableChapterItem(chapter: chapter);
      },
      itemCount: chapters.data.length,
    );
  }
}

class _SelectableChapterItem extends HookWidget {
  _SelectableChapterItem({
    Key key,
    @required this.chapter,
  }) : super(key: key);

  final Chapter chapter;

  @override
  Widget build(BuildContext context) {
    final state = _usePageState();
    final selected = state.isSelected(chapter);

    return InkWell(
      onTap: () {
        state.setSelected(chapter, !selected);
      },
      child: Padding(
        padding: const EdgeInsets.only(
          left: 4.0,
          right: 8.0,
        ),
        child: Row(
          children: <Widget>[
            Checkbox(
              value: selected,
              onChanged: (newValue) => state.setSelected(chapter, newValue),
            ),
            Flexible(
              child: Text(chapter.title),
            ),
          ],
        ),
      ),
    );
  }
}
