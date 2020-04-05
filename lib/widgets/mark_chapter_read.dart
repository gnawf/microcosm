import "dart:async";

import "package:app/hooks/use_daos.hook.dart";
import "package:app/models/chapter.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:meta/meta.dart";

void useReadingLog({
  @required Chapter chapter,
  Duration delay = const Duration(seconds: 30),
}) {
  assert(delay != null);

  final dao = useChapterDao();

  useEffect(() {
    if (chapter == null) {
      return () {};
    }

    final timer = Timer(delay, () {
      final now = DateTime.now();
      final read = chapter.copyWith(readAt: now);
      dao.upsert(read);
    });
    return timer.cancel;
  }, [chapter]);
}
