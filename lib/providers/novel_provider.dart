import "dart:async";
import "dart:convert" as convert;

import "package:app/models/novel.dart";
import "package:app/providers/database_provider.dart";
import "package:app/sources/database/novel_dao.dart";
import "package:flutter/material.dart";
import "package:meta/meta.dart";

class NovelProvider extends StatefulWidget {
  const NovelProvider({@required this.child});

  final Widget child;

  static NovelProviderState of(BuildContext context) {
    const matcher = const TypeMatcher<NovelProviderState>();
    return context.ancestorStateOfType(matcher);
  }

  @override
  State createState() => new NovelProviderState();
}

class NovelProviderState extends State<NovelProvider> {
  bool _ready = false;

  NovelDao _novelDao;

  NovelDao get dao => _novelDao;

  Future<Null> _populate() async {
    // Populate the database with local novel data
    final assetBundle = DefaultAssetBundle.of(context);
    final json = await assetBundle.loadString("assets/novels.json");
    final List<dynamic> objects = convert.json.decode(json);
    final novels = objects.map((x) => new Novel.fromJson(x));

    // Synchronously upsert all the novels
    for (final novel in novels) {
      await _novelDao.upsert(novel);
    }

    setState(() => _ready = true);
  }

  @override
  void initState() {
    super.initState();

    final databases = DatabaseProvider.of(context);
    _novelDao = new NovelDao(databases.database);

    _populate();
  }

  @override
  Widget build(BuildContext context) {
    return _ready ? widget.child : new Container(width: 0.0, height: 0.0);
  }
}
