import "dart:async";

import "package:app/models/chapter.dart";
import "package:app/providers/chapter_provider.dart";
import "package:flutter/material.dart";
import "package:meta/meta.dart";

class ListChapters extends StatefulWidget {
  const ListChapters({
    Key key,
    this.novelSlug,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  final String novelSlug;

  final AsyncWidgetBuilder<List<Chapter>> builder;

  @override
  State createState() => new _ListChaptersState();
}

class _ListChaptersState extends State<ListChapters> {
  Future<List<Chapter>> _chapters;

  Future<Null> _setup() async {
    if (!mounted) {
      return;
    }

    final chapters = ChapterProvider.of(context);
    final novelSlug = widget.novelSlug;

    // Todo - avoid hardcoding host here
    final host = new Uri(scheme: "https", host: "wuxiaworld.com");
    final source = chapters.source(host);

    setState(() {
      _chapters = source.list(novelSlug: novelSlug);
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
