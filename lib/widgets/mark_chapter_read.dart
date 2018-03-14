import "dart:async";

import "package:app/models/chapter.dart";
import "package:app/providers/chapter_provider.dart";
import "package:flutter/material.dart";
import "package:meta/meta.dart";

class MarkChapterRead extends StatefulWidget {
  const MarkChapterRead({
    @required this.chapter,
    this.delay = const Duration(seconds: 40),
    this.child,
  });

  final Chapter chapter;

  final Duration delay;

  final Widget child;

  @override
  State createState() => new _MarkChapterReadState();
}

class _MarkChapterReadState extends State<MarkChapterRead> {
  void _tick() {
    if (!mounted || widget.chapter == null) {
      return;
    }

    final chapters = ChapterProvider.of(context);

    // Note down the chapter so that we can cancel the ticking if it changes
    final slug = widget.chapter.slug;

    // Duration of each tick
    const duration = const Duration(milliseconds: 500);

    int ticks = 1;

    Future<Null> tock() async {
      // Tick
      await new Future.delayed(duration);

      if (!mounted || widget.chapter?.slug != slug) {
        return;
      }

      // If we've waited for long enough then mark the chapter as read
      if (duration * ticks >= widget.delay) {
        final now = new DateTime.now();
        final read = widget.chapter.copyWith(readAt: now);
        chapters.dao.upsert(read);
      } else {
        // Otherwise, keep ticking
        ticks++;
        tock();
      }
    }

    tock();
  }

  @override
  void initState() {
    super.initState();

    _tick();
  }

  @override
  void didUpdateWidget(MarkChapterRead oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.chapter?.slug != widget.chapter?.slug) {
      _tick();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
