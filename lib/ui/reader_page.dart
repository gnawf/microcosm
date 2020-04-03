import "package:app/hooks/use_chapter.hook.dart";
import 'package:app/markdown/markdown.widget.dart';
import "package:app/models/chapter.dart";
import "package:app/resource/resource.dart";
import "package:app/ui/router.hooks.dart";
import "package:app/widgets/chapter_overscoll_navigation.dart";
import "package:app/widgets/mark_chapter_read.dart";
import "package:app/widgets/md_icons.dart";
import "package:app/widgets/settings_icon_button.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:meta/meta.dart";

part "reader_page.hooks.dart";

class ReaderPage extends HookWidget {
  const ReaderPage(this.chapterUrl);

  final Uri chapterUrl;

  VoidCallback _refresh(Resource<Chapter> resource, ValueNotifier<bool> state) {
    return () async {
      state.value = true;
      await resource.refresh();
      state.value = false;
    };
  }

  @override
  Widget build(BuildContext context) {
    final chapter = useChapter(chapterUrl);
    final refreshing = useState(false);

    return _PageState(
      chapter: chapter,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: null,
          title: _Title(),
          centerTitle: false,
          actions: <Widget>[
            AnimatedOpacity(
              opacity: refreshing.value ? 0.4 : 1.0,
              duration: const Duration(milliseconds: 400),
              child: IconButton(
                icon: const Icon(MDIcons.refresh),
                tooltip: "Refresh",
                disabledColor: Theme.of(context).buttonColor,
                onPressed: refreshing.value || chapter.data == null ? null : _refresh(chapter, refreshing),
              ),
            ),
            const SettingsIconButton(),
          ],
        ),
        body: _Body(),
      ),
    );
  }
}

class _PageState extends HookWidget {
  const _PageState({
    Key key,
    Widget child,
    @required this.chapter,
  })  : _child = child,
        super(key: key);

  final Widget _child;

  final Resource<Chapter> chapter;

  @override
  Widget build(BuildContext context) {
    return _child;
  }
}

class _Title extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final pageState = _usePageState();
    final chapter = pageState.chapter;

    switch (chapter.state) {
      case ResourceState.placeholder:
        return const SizedBox.shrink();
      case ResourceState.loading:
        return const Text("Loading");
      case ResourceState.done:
        return Text(chapter.data?.title ?? "-");
      case ResourceState.error:
        return const Text("Error");
    }

    throw UnsupportedError("Switch was not exhaustive");
  }
}

class _Body extends HookWidget {
  const _Body({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageState = _usePageState();
    final chapter = pageState.chapter;
    final chapterNavigation = _useChapterNavigation();

    // Automatically marks chapter as read after delay
    useReadingLog(chapter: chapter.data);

    switch (chapter.state) {
      case ResourceState.placeholder:
        return const SizedBox.shrink();
      case ResourceState.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case ResourceState.error:
        return Text("${chapter.error}");
      case ResourceState.done:
        break;
    }

    return ChapterOverscrollNavigation(
      onNavigate: chapterNavigation,
      child: _MarkdownBody(
        data: chapter.data?.content,
      ),
    );
  }
}

class _MarkdownBody extends PerformantMarkdownWidget {
  const _MarkdownBody({
    String data,
    MarkdownTapLinkCallback onTapLink,
  }) : super(
          data: data,
          onTapLink: onTapLink,
        );

  @override
  Widget build(BuildContext context, List<Widget> children) {
    final hasChildren = children?.isNotEmpty == true;

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      children: <Widget>[
        _Navigation(),
        if (children == null) _RenderingChapter(),
        if (hasChildren) ...children,
        if (hasChildren) _Navigation(),
      ],
    );
  }
}

class _RenderingChapter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: const [
          CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
            ),
            child: Text("Rendering Chapter"),
          ),
        ],
      ),
    );
  }
}

class _Navigation extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final pageState = _usePageState();
    final chapter = pageState.chapter.data;

    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        new _NavigationButton(
          url: chapter.previousUrl,
          child: const Text("Previous Chapter"),
        ),
        new _NavigationButton(
          url: chapter.nextUrl,
          child: const Text("Next Chapter"),
        ),
      ],
    );
  }
}

class _NavigationButton extends HookWidget {
  const _NavigationButton({@required this.child, this.url});

  final Widget child;

  final Uri url;

  @override
  Widget build(BuildContext context) {
    return new FlatButton(
      padding: EdgeInsets.zero,
      onPressed: _useOpenReader(url),
      child: child,
    );
  }
}

class _DownloadChaptersButton extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(MDIcons.download),
      tooltip: "Download",
      onPressed: _useOpenDownloadChapters(),
    );
  }
}
