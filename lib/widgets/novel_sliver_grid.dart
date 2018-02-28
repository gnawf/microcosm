import "package:app/models/novel.dart";
import "package:app/widgets/image_view.dart";
import "package:flutter/material.dart";

class NovelSliverGrid extends StatefulWidget {
  const NovelSliverGrid();

  @override
  State createState() => new _NovelSliverGridState();
}

class _NovelSliverGridState extends State<NovelSliverGrid> {
  List<Novel> novels;

  Widget _builder(BuildContext context, int index) {
    return new NovelGridItem(novels[index]);
  }

  @override
  void initState() {
    super.initState();
    novels = <Novel>[
      const Novel(
        slug: "issth-index",
        name: "I Shall Seal the Heavens",
        posterImage: "https://cdn.novelupdates.com/images/2015/06/15_ISSTH.jpg",
      ),
      const Novel(
        slug: "desolate-era-index",
        name: "Desolate Era",
        posterImage:
            "https://cdn.novelupdates.com/images/2015/06/Cover-Mang-Huang-Ji.jpg",
      ),
      const Novel(
        slug: "awe-index",
        name: "A Will Eternal",
        posterImage:
            "https://cdn.novelupdates.com/images/2016/06/betacover.jpg",
      ),
      const Novel(
        slug: "renegade-index",
        name: "Renegade Immortal",
        posterImage: "https://cdn.novelupdates.com/images/2016/03/xianni-1.jpg",
      ),
      const Novel(
        slug: "cdindex-html",
        name: "Coiling Dragon",
        posterImage: "https://cdn.novelupdates.com/images/2016/03/s4437529.jpg",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
