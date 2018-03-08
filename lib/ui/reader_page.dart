import "package:app/models/chapter.dart";
import "package:app/settings/settings.dart";
import "package:app/ui/routes.dart" as routes;
import "package:app/utils/url_launcher.dart";
import "package:app/widgets/chapter_holder.dart";
import "package:app/widgets/settings_icon_button.dart";
import "package:flutter/material.dart";
import "package:flutter_markdown/flutter_markdown.dart";
import "package:meta/meta.dart";

class ReaderPage extends StatelessWidget {
  const ReaderPage(this.chapterUrl);

  final Uri chapterUrl;

  @override
  Widget build(BuildContext context) {
    return new ChapterHolder(
      url: chapterUrl,
      builder: (BuildContext context, AsyncSnapshot<Chapter> snapshot) {
        final chapter = snapshot.data;

        // Store the latest chapter URL
        if (chapter?.url != null) {
          final settings = Settings.of(context);
          settings.lastChapterUrl = chapter.url.toString();
        }

        return new Scaffold(
          appBar: new AppBar(
            automaticallyImplyLeading: false,
            leading: null,
            title: new Text(
              chapter?.title ?? "Loading",
            ),
            centerTitle: false,
            actions: const <Widget>[
              const SettingsIconButton(),
            ],
          ),
          body: new _ReaderPageBody(chapter),
        );
      },
    );
  }
}

class _ReaderPageBody extends StatelessWidget {
  const _ReaderPageBody(this.chapter);

  final Chapter chapter;

  @override
  Widget build(BuildContext context) {
    if (chapter == null) {
      return const Center(
        child: const CircularProgressIndicator(),
      );
    }

    return new ListView(
      padding: const EdgeInsets.symmetric(
        vertical: 24.0,
      ),
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 3.0,
          ),
          child: new _ChapterActions(chapter),
        ),
        new Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18.0,
            vertical: 16.0,
          ),
          child: new _ChapterBody(chapter),
        ),
        new Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 3.0,
          ),
          child: new _ChapterActions(chapter),
        ),
      ],
    );
  }
}

class _ChapterBody extends StatefulWidget {
  const _ChapterBody(this.chapter);

  final Chapter chapter;

  @override
  State<StatefulWidget> createState() => new _ChapterBodyState();
}

class _ChapterBodyState extends State<_ChapterBody> {
  VoidCallback _dispose;

  void _invalidate() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    final settings = Settings.of(context);
    settings.readerFontSizeChanges.addListener(_invalidate);
    _dispose = () => settings.readerFontSizeChanges.removeListener(_invalidate);
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chapter = widget.chapter;

    final settings = Settings.of(context);
    final theme = Theme.of(context);
    final ss = new MarkdownStyleSheet.fromTheme(theme);

    return new MarkdownBody(
      data: chapter.content,
      styleSheet: ss.copyWith(
        p: ss.p.copyWith(height: 1.4, fontSize: settings.readerFontSize),
      ),
      onTapLink: (link) => onTapLink(context, link),
    );
  }
}

class _ChapterActions extends StatelessWidget {
  const _ChapterActions(this.chapter);

  final Chapter chapter;

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        new _ChapterButton(
          url: chapter.previousUrl,
          child: const Text("Previous Chapter"),
        ),
        new _ChapterButton(
          url: chapter.nextUrl,
          child: const Text("Next Chapter"),
        ),
      ],
    );
  }
}

class _ChapterButton extends StatelessWidget {
  const _ChapterButton({@required this.child, this.url});

  final Widget child;

  final Uri url;

  void _open(BuildContext context) {
    Navigator.of(context).pushReplacement(routes.reader(url: url));
  }

  @override
  Widget build(BuildContext context) {
    return new FlatButton(
      onPressed: url != null ? () => _open(context) : null,
      child: child,
    );
  }
}
