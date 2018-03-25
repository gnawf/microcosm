import "package:app/models/novel.dart";
import "package:app/widgets/custom_sliver_grid.dart";
import "package:app/widgets/image_view.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";

typedef void OnTapNovel(Novel novel);

class NovelSliverGrid extends StatefulWidget {
  const NovelSliverGrid({this.novels = const <Novel>[], this.onTap});

  final List<Novel> novels;

  final OnTapNovel onTap;

  @override
  State createState() => new _NovelSliverGridState();
}

class _NovelSliverGridState extends State<NovelSliverGrid> {
  Widget _builder(BuildContext context, int index) {
    return new NovelGridItem(widget.novels[index], widget.onTap);
  }

  @override
  Widget build(BuildContext context) {
    final novels = widget.novels;

    return new CustomSliverGrid(
      builder: _builder,
      cellWidth: 90.0,
      cellCount: novels.length,
      rowSpacing: 8.0,
      columnSpacing: 16.0,
    );
  }
}

class NovelGridItem extends StatefulWidget {
  const NovelGridItem(this.novel, this.onTap);

  final Novel novel;

  final OnTapNovel onTap;

  @override
  State<StatefulWidget> createState() => new _NovelGridItemState();
}

class _NovelGridItemState extends State<NovelGridItem>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = new Tween(begin: 1.0, end: 0.9).animate(
      new CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final novel = widget.novel;
    final onTap = widget.onTap;

    return new GestureDetector(
      onTap: onTap != null ? () => onTap(novel) : null,
      // Start the scale transition on tap
      onTapDown: (event) => _controller.forward(),
      onTapUp: (event) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      // Scale the entire widget upon request
      child: new ScaleTransition(
        scale: _scaleAnimation,
        child: new Column(
          children: <Widget>[
            new AspectRatio(
              aspectRatio: 102.0 / 145.0,
              child: new Hero(
                tag: novel.slug,
                child: new ImageView(
                  image: novel.posterImage,
                  fit: BoxFit.cover,
                ),
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
        ),
      ),
    );
  }
}
