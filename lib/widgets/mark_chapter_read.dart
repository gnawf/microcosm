import "dart:async";

import "package:app/models/chapter.dart";
import "package:app/providers/chapter_provider.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:meta/meta.dart";

void useReadingLog({
  @required Chapter chapter,
  Duration delay = const Duration(seconds: 30),
}) {
  assert(chapter != null);
  assert(delay != null);

  final context = useContext();
  final chapters = ChapterProvider.of(context);

  useEffect(() {
    final timer = new Timer(delay, () {
      final now = new DateTime.now();
      final read = chapter.copyWith(readAt: now);
      chapters.dao.upsert(read);
    });
    return () {
      timer.cancel();
    };
  });
}
