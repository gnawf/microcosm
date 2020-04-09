import "package:app/models/novel.dart";
import "package:app/resource/paginated_resource.dart";
import "package:app/widgets/custom_sliver_grid.dart";
import "package:app/widgets/image_view.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";

typedef void OnTapNovel(Novel novel);

class NovelSliverGrid extends StatefulWidget {
  const NovelSliverGrid({this.novels, this.onTap});

  final PaginatedResource<Novel> novels;

  final OnTapNovel onTap;

  @override
  State createState() => _NovelSliverGridState();
}

class _NovelSliverGridState extends State<NovelSliverGrid> {
  var loading = false;

  Widget _builder(BuildContext context, int index) {
    if (index == widget.novels.data.length) {
      if (!loading) {
        loading = true;
        widget.novels.fetchMore().then((value) {
          loading = false;
        });
      }
      return const Padding(
        padding: EdgeInsets.only(
          top: 48.0,
        ),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return NovelGridItem(widget.novels.data[index], widget.onTap);
  }

  @override
  Widget build(BuildContext context) {
    final novels = widget.novels;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 18.0,
      ),
      sliver: CustomSliverGrid(
        builder: _builder,
        cellWidth: 90.0,
        cellCount: novels.data.length + (novels.hasMore ? 1 : 0),
        rowSpacing: 8.0,
        columnSpacing: 16.0,
      ),
    );
  }
}

class NovelGridItem extends StatefulWidget {
  const NovelGridItem(this.novel, this.onTap);

  final Novel novel;

  final OnTapNovel onTap;

  @override
  State<StatefulWidget> createState() => _NovelGridItemState();
}

class _NovelGridItemState extends State<NovelGridItem> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final novel = widget.novel;
    final onTap = widget.onTap;

    return GestureDetector(
      onTap: onTap != null ? () => onTap(novel) : null,
      // Start the scale transition on tap
      onTapDown: (event) => _controller.forward(),
      onTapUp: (event) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      // Scale the entire widget upon request
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 102.0 / 145.0,
              child: Hero(
                tag: novel.slug,
                child: ImageView(
                  image: novel.posterImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
              ),
              child: Text(
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
