import "package:app/models/novel.dart";
import "package:app/ui/novel_header.dart";
import "package:app/widgets/novel_holder.dart";
import "package:flutter/material.dart";

class NovelPage extends StatelessWidget {
  const NovelPage(this.slug, [this.novel]);

  final String slug;

  final Novel novel;

  @override
  Widget build(BuildContext context) {
    return new NovelHolder(
      slug: slug,
      novel: novel,
      builder: (BuildContext context, AsyncSnapshot<Novel> snapshot) {
        final novel = snapshot.data;

        return new Scaffold(
          appBar: new AppBar(
            automaticallyImplyLeading: false,
            leading: null,
            title: new Text(novel?.name ?? ""),
            centerTitle: false,
          ),
          body: new _NovelPageBody(novel),
        );
      },
    );
  }
}

class _NovelPageBody extends StatefulWidget {
  const _NovelPageBody(this.novel);

  final Novel novel;

  @override
  State createState() => new _NovelPageBodyState();
}

class _NovelPageBodyState extends State<_NovelPageBody> {
  @override
  Widget build(BuildContext context) {
    final novel = widget.novel;

    return new ListView(
      children: <Widget>[
        new Column(
          children: <Widget>[
            new NovelHeader(novel),
          ],
        )
      ],
    );
  }
}
