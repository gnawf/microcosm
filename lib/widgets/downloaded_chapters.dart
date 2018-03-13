import "dart:async";

import "package:app/models/chapter.dart";
import "package:app/providers/chapter_provider.dart";
import "package:flutter/material.dart";
import "package:meta/meta.dart";

class DownloadedChapters extends StatefulWidget {
  const DownloadedChapters({
    Key key,
    this.novelSlug,
    @required this.builder,
  }) : super(key: key);

  final String novelSlug;

  final AsyncWidgetBuilder<List<Chapter>> builder;

  @override
  State createState() => new DownloadedChaptersState();
}

class DownloadedChaptersState extends State<DownloadedChapters> {
  Future<List<Chapter>> _chapters;

  void refresh() => _setup();

  Future<Null> _setup() async {
    if (!mounted) {
      return;
    }

    final slug = widget.novelSlug;

    final chapters = ChapterProvider.of(context);

    setState(() {
      // Todo - paginate this
      _chapters = chapters.dao.list(novelSlug: slug, orderBy: "slug");
    });
  }

  @override
  void initState() {
    super.initState();

    _setup();
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      builder: widget.builder,
      future: _chapters,
    );
  }
}
