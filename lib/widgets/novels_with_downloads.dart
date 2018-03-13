import "dart:async";

import "package:app/models/novel.dart";
import "package:app/providers/novel_provider.dart";
import "package:flutter/material.dart";
import "package:meta/meta.dart";

class NovelsWithDownloads extends StatefulWidget {
  const NovelsWithDownloads({
    Key key,
    @required this.builder,
  }) : super(key: key);

  final AsyncWidgetBuilder<List<Novel>> builder;

  @override
  State createState() => new NovelsWithDownloadsState();
}

class NovelsWithDownloadsState extends State<NovelsWithDownloads> {
  Future<List<Novel>> _novels;

  void refresh() => _setup();

  Future<Null> _setup() async {
    if (!mounted) {
      return;
    }

    final novels = NovelProvider.of(context);
    final dao = novels.dao;

    setState(() {
      _novels = dao.withDownloads();
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
      future: _novels,
    );
  }
}
