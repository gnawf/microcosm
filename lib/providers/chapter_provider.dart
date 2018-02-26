import "package:app/sources/chapter_source.dart";
import "package:app/sources/wuxia_world/wuxia_world_chapters.dart";
import "package:flutter/material.dart";
import "package:meta/meta.dart";

class ChapterProvider extends StatefulWidget {
  const ChapterProvider({@required this.child});

  final Widget child;

  static ChapterProviderState of(BuildContext context) {
    const matcher = const TypeMatcher<ChapterProviderState>();
    return context.ancestorStateOfType(matcher);
  }

  @override
  State createState() => new ChapterProviderState();
}

class ChapterProviderState extends State<ChapterProvider> {
  final _wuxiaWorldChapters = const WuxiaWorldChapters(
    const WuxiaWorldChapterParser(),
  );

  ChapterSource source(Uri url) {
    switch (url.host) {
      case "wuxiaworld.com":
      case "m.wuxiaworld.com":
      case "www.wuxiaworld.com":
        return _wuxiaWorldChapters;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
