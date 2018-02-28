import "package:app/widgets/novel_sliver_grid.dart";
import "package:flutter/material.dart";

class RecentsPage extends StatelessWidget {
  const RecentsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        title: const Text("Recently Read"),
        centerTitle: false,
      ),
      body: new CustomScrollView(
        slivers: const <Widget>[
          const SliverPadding(
            padding: const EdgeInsets.symmetric(
              vertical: 24.0,
              horizontal: 16.0,
            ),
            sliver: const NovelSliverGrid(),
          ),
        ],
      ),
    );
  }
}
