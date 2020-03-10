import "dart:async";

import "package:app/models/chapter.dart";
import "package:app/providers/chapter_provider.dart";
import "package:app/widgets/refresh_notification.dart";
import "package:flutter/material.dart";

class ChapterHolder extends StatefulWidget {
  const ChapterHolder({
    this.slug,
    this.url,
    this.preload = true,
    this.builder,
  });

  final String slug;

  final Uri url;

  final bool preload;

  final AsyncWidgetBuilder<Chapter> builder;

  @override
  State createState() => new ChapterHolderState();
}

class ChapterHolderState extends State<ChapterHolder> {
  Future<Chapter> _chapter;

  bool _onRefresh(RefreshNotification notification) {
    // If the notification isn't for us, continue bubbling
    if (notification.what != ChapterHolder) {
      return false;
    }

    // Reload
    _setup(fromCache: false, complete: notification.complete);
    return true;
  }

  Future<Null> _preload(Uri url) async {
    if (!mounted || widget.preload == false || url == null) {
      return;
    }

    final chapters = ChapterProvider.of(context);
    final dao = chapters.dao;

    if (!await dao.exists(url: url)) {
      final source = chapters.source(url: url);
      dao.upsert(await source.get(url: url));
    }
  }

  Future<Chapter> _dao(String slug, Uri url) {
    if (!mounted) {
      return null;
    }

    final chapters = ChapterProvider.of(context);
    final dao = chapters.dao;

    return dao.get(slug: slug, url: url).then((chapter) {
      if (chapter == null) {
        return null;
      }

      _preload(chapter.nextUrl);
      return chapter;
    });
  }

  Future<Chapter> _source(String slug, Uri url) {
    if (!mounted) {
      return null;
    }

    final chapters = ChapterProvider.of(context);
    final dao = chapters.dao;
    final source = chapters.source(url: url);

    return source.get(slug: slug, url: url).then((chapter) async {
      if (chapter == null) {
        return null;
      }

      _preload(chapter.nextUrl);
      dao.upsert(chapter);
      return chapter;
    });
  }

  Future<Null> _setup({bool fromCache: true, VoidCallback complete}) async {
    if (!mounted) {
      return;
    }

    final slug = widget.slug;
    final url = widget.url;

    setState(() {
      if (fromCache == false) {
        _chapter = _source(slug, url).then((chapter) {
          // Fallback to dao
          return chapter == null ? _dao(slug, url) : chapter;
        });
      } else {
        _chapter = _dao(slug, url).then((chapter) {
          // Fallback to source
          return chapter == null ? _source(slug, url) : chapter;
        });
      }
    });

    if (complete != null) {
      _chapter.whenComplete(complete);
    }
  }

  @override
  void initState() {
    super.initState();

    _setup();
  }

  @override
  void didUpdateWidget(ChapterHolder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.slug != widget.slug || oldWidget.url != widget.url) {
      _setup();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new NotificationListener<RefreshNotification>(
      onNotification: _onRefresh,
      child: new FutureBuilder<Chapter>(
        builder: widget.builder,
        future: _chapter,
      ),
    );
  }
}
