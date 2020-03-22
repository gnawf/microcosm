import "dart:async";

import "package:app/models/chapter.dart";
import "package:app/providers/chapter_provider.dart";
import "package:app/resource/resource.dart";
import "package:app/resource/resource.hooks.dart";
import "package:app/sources/chapter_source.dart";
import "package:app/ui/routes.dart" as routes;
import "package:app/utils/url_launcher.dart";
import "package:app/widgets/mark_chapter_read.dart";
import "package:app/widgets/settings_icon_button.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:flutter_markdown/flutter_markdown.dart";
import "package:markdown/markdown.dart" as md;
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
          automaticallyImplyLeading: false,
          leading: null,
          title: _Title(),
          centerTitle: false,
          actions: const <Widget>[
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
    final pageState = usePageState();
    final chapter = pageState.chapter;

    switch (chapter.state) {
      case ResourceState.placeholder:
        return Container(width: 0.0, height: 0.0);
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
  @override
  Widget build(BuildContext context) {
    final pageState = usePageState();
    final chapter = pageState.chapter;

    switch (chapter.state) {
      case ResourceState.placeholder:
        return Container(width: 0.0, height: 0.0);
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
      onRefresh: pageState.chapter.refresh,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 3.0,
          vertical: 24.0,
        ),
        children: <Widget>[
          _Navigation(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _Content(),
          ),
          _Navigation(),
        ],
      ),
    );
  }
}

class _Content extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final pageState = usePageState();
    final chapter = pageState.chapter.data;

    // Automatically marks chapter as read after delay
    useReadingLog(chapter: chapter);

    return new MarkdownBody(
      data: "${chapter.content}",
      extensionSet: md.ExtensionSet.none,
      onTapLink: (link) => onTapLink(context, link),
    );
  }
}

class _Navigation extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final pageState = usePageState();
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

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({@required this.child, this.url});

  final Widget child;

  final Uri url;

  void _open(BuildContext context) {
    final reader = routes.reader(url: url);
    Navigator.of(context).pushReplacement(reader);
  }

  @override
  Widget build(BuildContext context) {
    return new FlatButton(
      onPressed: url != null ? () => _open(context) : null,
      child: child,
    );
  }
}
