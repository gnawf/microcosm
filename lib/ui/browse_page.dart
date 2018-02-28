import "package:app/models/novel.dart";
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
          const SliverPadding(
            padding: const EdgeInsets.symmetric(
              vertical: 24.0,
              horizontal: 16.0,
            ),
            sliver: const NovelSliverGrid(
              novels: const <Novel>[
                const Novel(
                  slug: "issth-index",
                  name: "I Shall Seal the Heavens",
                  posterImage:
                      "https://cdn.novelupdates.com/images/2015/06/15_ISSTH.jpg",
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
                  posterImage:
                      "https://cdn.novelupdates.com/images/2016/03/xianni-1.jpg",
                ),
                const Novel(
                  slug: "cdindex-html",
                  name: "Coiling Dragon",
                  synopsis: "",
                  posterImage:
                      "https://cdn.novelupdates.com/images/2016/03/s4437529.jpg",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
