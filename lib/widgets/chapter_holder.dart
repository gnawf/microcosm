import "dart:async";

import "package:app/models/chapter.dart";
import "package:app/providers/chapter_provider.dart";
import "package:flutter/material.dart";

class ChapterHolder extends StatefulWidget {
  const ChapterHolder({this.slug, this.url, this.preload: true, this.builder});

  final String slug;

  final Uri url;

  final bool preload;

  final AsyncWidgetBuilder<Chapter> builder;

  @override
  State createState() => new ChapterHolderState();
}

class ChapterHolderState extends State<ChapterHolder> {
  Future<Chapter> _chapter;

  Future<Null> _preload(Uri url) async {
    if (!mounted || widget.preload == false || url == null) {
      return;
    }

    final chapters = ChapterProvider.of(context);
    final dao = chapters.dao;

    if (!await dao.exists(url: url)) {
      final source = chapters.source(url);
      dao.upsert(await source.get(url: url));
    }
  }

  Future<Null> _setup() async {
    if (!mounted) {
      return;
    }

    final slug = widget.slug;
    final url = widget.url;

    final chapters = ChapterProvider.of(context);
    final dao = chapters.dao;
    final source = chapters.source(url);

    setState(() {
      _chapter = dao.get(slug: slug, url: url).then((chapter) {
        if (chapter == null) {
          // If we can't find anything locally then load it from the source
          return source.get(slug: slug, url: url).then((chapter) async {
            if (chapter == null) {
              return null;
            }
            _preload(chapter.nextUrl);
            // Save the chapter
            dao.upsert(chapter);
            return chapter;
          });
        }

        _preload(chapter.nextUrl);
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
