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

  Future<Null> _setup() async {
    if (!mounted) {
      return;
    }

    final source = ChapterProvider.of(context).source(widget.url);

    setState(() {
      _chapter = source.get(slug: widget.slug, url: widget.url);
    });
  }

  @override
  void initState() {
    super.initState();

    _setup();
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<Chapter>(
      builder: widget.builder,
      future: _chapter,
    );
  }
}
