import "dart:async";

import "package:app/models/chapter.dart";
import "package:app/providers/chapter_provider.dart";
import "package:flutter/material.dart";
import "package:meta/meta.dart";

class DownloadedChapters extends StatefulWidget {
  const DownloadedChapters({
    Key key,
    this.novelSource,
    this.novelSlug,
    @required this.builder,
  }) : super(key: key);

  final String novelSource;

  final String novelSlug;

  final AsyncWidgetBuilder<List<Chapter>> builder;

  @override
  State createState() => DownloadedChaptersState();
}

class DownloadedChaptersState extends State<DownloadedChapters> {
  Future<List<Chapter>> _chapters;

  void refresh() => _setup();

  Future<void> _setup() async {
    if (!mounted) {
      return;
    }

    final chapters = ChapterProvider.of(context);

    setState(() {
      // Todo - paginate this
      _chapters = chapters.dao.list(
        novelSource: widget.novelSource,
        novelSlug: widget.novelSlug,
        orderBy: "slug",
      );
    });
  }

  @override
  void initState() {
    super.initState();

    _setup();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: widget.builder,
      future: _chapters,
    );
  }
}
