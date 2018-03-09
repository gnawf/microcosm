import "dart:async";

import "package:app/models/chapter.dart";
import "package:app/providers/chapter_provider.dart";
import "package:flutter/material.dart";

class ChapterHolder extends StatefulWidget {
  const ChapterHolder({this.slug, this.url, this.builder});

  final String slug;

  final Uri url;

  final AsyncWidgetBuilder<Chapter> builder;

  @override
  State createState() => new ChapterHolderState();
}

class ChapterHolderState extends State<ChapterHolder> {
  Future<Chapter> _chapter;

  Future<Null> _preload(Chapter chapter) async {
    if (!mounted) {
      return;
    }

    final chapterProvider = ChapterProvider.of(context);
    final dao = chapterProvider.dao();
    final source = chapterProvider.source(widget.url);
    final url = chapter.nextUrl;

    if ((await dao.get(url: url)) == null) {
      dao.upsert(await source.get(url: url));
    }
  }

  Future<Null> _setup() async {
    if (!mounted) {
      return;
    }

    final slug = widget.slug;
    final url = widget.url;

    final chapterProvider = ChapterProvider.of(context);
    final dao = chapterProvider.dao();
    final source = chapterProvider.source(url);

    setState(() {
      _chapter = dao.get(slug: slug, url: url).then((chapter) {
        if (chapter == null) {
          // If we can't find anything locally then load it remotely
          return source.get(slug: slug, url: url).then((chapter) async {
            _preload(chapter);
            // Save the chapter
            dao.upsert(chapter);
            return chapter;
          });
        }
        return chapter;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _setup();
  }

  @override
  void didUpdateWidget(ChapterHolder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.slug != widget.slug || oldWidget.url != widget.url) {
      _setup();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<Chapter>(
      builder: widget.builder,
      future: _chapter,
    );
  }
}
