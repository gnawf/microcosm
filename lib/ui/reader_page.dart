import "package:app/hooks/use_chapter.hook.dart";
import "package:app/hooks/use_settings.hook.dart";
import "package:app/hooks/use_theme.hook.dart";
import "package:app/markdown/markdown.widget.dart";
import "package:app/models/chapter.dart";
import "package:app/resource/resource.dart";
import "package:app/ui/router.hooks.dart";
import "package:app/utils/scaffold.extensions.dart";
import "package:app/widgets/chapter_overscoll_navigation.dart";
import "package:app/widgets/mark_chapter_read.dart";
import "package:app/widgets/md_icons.dart";
import "package:app/widgets/settings_icon_button.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:flutter_markdown/flutter_markdown.dart";
import "package:meta/meta.dart";

part "reader_page.hooks.dart";

class ReaderPage extends HookWidget {
  const ReaderPage(this.chapterUrl);

  final Uri chapterUrl;

  @override
  Widget build(BuildContext context) {
    final chapter = useChapter(chapterUrl);

    return _PageState(
      chapter: chapter,
      child: Scaffold(
        appBar: AppBar(
          title: _Title(),
          centerTitle: false,
          actions: [
            _DownloadChaptersButton(),
            const SettingsIconButton(),
          ],
        ),
        body: _Body(),
      ),
    );
  }
}

class _PageState extends HookWidget {
  _PageState({
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
  _Body({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageState = _usePageState();
    final chapter = pageState.chapter;
    final chapterNavigation = _useChapterNavigation();
    final styleSheet = _useMarkdownStyleSheet();

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

    return RefreshIndicator(
      onRefresh: chapter.refresh,
      child: ChapterOverscrollNavigation(
        onNavigate: chapterNavigation,
        child: _MarkdownBody(
          data: chapter.data?.content,
          styleSheet: styleSheet,
        ),
      ),
    );
  }
}

class _MarkdownBody extends PerformantMarkdownWidget {
  const _MarkdownBody({
    String data,
    MarkdownTapLinkCallback onTapLink,
    MarkdownStyleSheet styleSheet,
  }) : super(
          data: data,
          onTapLink: onTapLink,
          styleSheet: styleSheet,
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _NavigationButton(
          url: chapter.previousUrl,
          child: const Text("Previous Chapter"),
        ),
        _NavigationButton(
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
    return FlatButton(
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
