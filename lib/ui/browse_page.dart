import "dart:async";

import "package:app/models/novel.dart";
import "package:app/providers/novel_provider.dart";
import "package:app/ui/routes.dart" as routes;
import "package:app/widgets/novel_sliver_grid.dart";
import "package:app/widgets/settings_icon_button.dart";
import "package:flutter/material.dart";

class BrowsePage extends StatelessWidget {
  const BrowsePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        title: const Text("Browse"),
        centerTitle: false,
        actions: const <Widget>[
          const SettingsIconButton(),
        ],
      ),
      body: new CustomScrollView(
        slivers: const <Widget>[
          const _Grid(),
        ],
      ),
    );
  }
}

class _Grid extends StatefulWidget {
  const _Grid();

  @override
  State createState() => new _GridState();
}

class _GridState extends State<_Grid> {
  final _novels = <Novel>[];

  void _open(Novel novel) {
    Navigator.of(context).push(routes.novel(novel: novel));
  }

  Future<Null> _load() async {
    if (!mounted) {
      return;
    }

    final novels = NovelProvider.of(context);
    final dao = novels.dao;
    final results = await dao.list();
    results.sort((a, b) => a.name.compareTo(b.name));
    setState(() => _novels.addAll(results));
  }

  @override
  void initState() {
    super.initState();

    _load();
  }

  @override
  Widget build(BuildContext context) {
    return new SliverPadding(
      padding: const EdgeInsets.only(
        top: 24.0,
        left: 16.0,
        right: 16.0,
        bottom: 16.0,
      ),
      sliver: new NovelSliverGrid(
        novels: _novels,
        onTap: _open,
      ),
    );
  }
}
