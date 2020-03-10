import "dart:async";

import "package:app/models/novel.dart";
import "package:app/providers/novel_provider.dart";
import "package:flutter/material.dart";
import "package:meta/meta.dart";

class NovelHolder extends StatefulWidget {
  const NovelHolder({
    this.slug,
    this.source,
    this.novel,
    @required this.builder,
  }) : assert((slug != null && source != null) || novel != null);

  final String slug;

  final String source;

  final Novel novel;

  final AsyncWidgetBuilder<Novel> builder;

  @override
  State createState() => new _NovelHolderState();
}

class _NovelHolderState extends State<NovelHolder> {
  Future<Novel> _novel;

  Future<Null> _setup() async {
    if (!mounted) {
      return;
    }

    final slug = widget.slug;
    final source = widget.source;

    final novels = NovelProvider.of(context);
    final dao = novels.dao;

    setState(() {
      _novel = dao.get(slug: slug, source: source);
    });
  }

  @override
  void initState() {
    super.initState();

    _setup();
  }

  @override
  void didUpdateWidget(NovelHolder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.slug != widget.slug) {
      _setup();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<Novel>(
      builder: widget.builder,
      future: _novel,
      initialData: widget.novel,
    );
  }
}
