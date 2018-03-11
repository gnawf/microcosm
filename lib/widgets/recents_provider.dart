import "dart:async";

import "package:app/models/chapter.dart";
import "package:app/providers/chapter_provider.dart";
import "package:flutter/material.dart";
import "package:meta/meta.dart";

class RecentsProvider extends StatefulWidget {
  const RecentsProvider({Key key, @required this.builder}) : super(key: key);

  final AsyncWidgetBuilder<List<Chapter>> builder;

  @override
  State createState() => new RecentsProviderState();
}

class RecentsProviderState extends State<RecentsProvider> {
  Future<List<Chapter>> _recents;

  void refresh() => _setup();

  Future<Null> _setup() async {
    if (!mounted) {
      return;
    }

    final chapters = ChapterProvider.of(context);
    final dao = chapters.dao;

    setState(() {
      _recents = dao.recents();
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
      future: _recents,
    );
  }
}
