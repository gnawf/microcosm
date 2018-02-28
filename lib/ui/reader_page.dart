import "package:app/models/chapter.dart";
import "package:app/settings/settings.dart";
import "package:app/ui/routes.dart" as routes;
import "package:app/widgets/chapter_holder.dart";
import "package:app/widgets/settings_icon_button.dart";
import "package:flutter/material.dart";
import "package:flutter_markdown/flutter_markdown.dart";

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
          body: new ReaderPageBody(chapter),
        );
      },
    );
  }
}

class ReaderPageBody extends StatelessWidget {
  const ReaderPageBody(this.chapter);

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
          child: new ChapterActions(chapter),
        ),
        new Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18.0,
            vertical: 16.0,
          ),
          child: new ChapterBody(chapter),
        ),
        new Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 3.0,
          ),
          child: new ChapterActions(chapter),
        ),
      ],
    );
  }
}

class ChapterBody extends StatelessWidget {
  const ChapterBody(this.chapter);

  final Chapter chapter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ss = new MarkdownStyleSheet.fromTheme(theme);

    return new MarkdownBody(
      data: chapter.content,
      styleSheet: ss.copyWith(
        p: ss.p.copyWith(height: 1.4),
      ),
    );
  }
}

class ChapterActions extends StatelessWidget {
  const ChapterActions(this.chapter);

  final Chapter chapter;

  void _open(BuildContext context, Uri url) {
    Navigator.of(context).pushReplacement(routes.reader(url: url));
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        new FlatButton(
          onPressed: () => _open(context, chapter.previousUrl),
          child: const Text("Previous Chapter"),
        ),
        new FlatButton(
          onPressed: () => _open(context, chapter.nextUrl),
          child: const Text("Next Chapter"),
        ),
      ],
    );
  }
}
