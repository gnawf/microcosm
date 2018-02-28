import "package:app/models/novel.dart";
import "package:app/widgets/image_view.dart";
import "package:flutter/material.dart";

class NovelSliverGrid extends StatefulWidget {
  const NovelSliverGrid({this.novels: const <Novel>[]});

  final List<Novel> novels;

  @override
  State createState() => new _NovelSliverGridState();
}

class _NovelSliverGridState extends State<NovelSliverGrid> {
  Widget _builder(BuildContext context, int index) {
    return new NovelGridItem(widget.novels[index]);
  }

  @override
  Widget build(BuildContext context) {
    final novels = widget.novels;

    return new SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 115.0,
        crossAxisSpacing: 16.0,
        childAspectRatio: 0.48,
      ),
      delegate: new SliverChildBuilderDelegate(
        _builder,
        childCount: novels.length,
      ),
    );
  }
}

class NovelGridItem extends StatelessWidget {
  const NovelGridItem(this.novel);

  final Novel novel;

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new AspectRatio(
          aspectRatio: 102.0 / 145.0,
          child: new ImageView(
            image: novel.posterImage,
            fit: BoxFit.cover,
          ),
        ),
        new Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
          ),
          child: new Text(
            novel.name,
            maxLines: 3,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
