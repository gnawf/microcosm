import "dart:async";

import "package:app/models/novel.dart";
import "package:app/providers/provider.hooks.dart";
import "package:app/resource/resource.dart";
import "package:app/resource/resource.hooks.dart";
import "package:app/sources/sources.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:meta/meta.dart";

typedef _NovelFetcher = Future<Novel> Function({
  @required String slug,
});

typedef _SaveNovel = FutureOr<void> Function(Novel novel);

_NovelFetcher _save(_NovelFetcher fetcher, _SaveNovel save) {
  return ({String slug}) async {
    final novel = await fetcher(slug: slug);
    await save(novel);
    return novel;
  };
}

Resource<Novel> useNovel(String source, String slug) {
  final dao = useNovelDao();
  final novelSource = useSource(source).novels;
  final novel = useResource<Novel>();

  useEffect(() {
    () async {
      final _SaveNovel save = dao.upsert;

      for (final fetcher in <_NovelFetcher>[
        ({String slug}) => dao.get(source: source, slug: slug),
        _save(novelSource.get, save),
      ]) {
        try {
          final value = await fetcher(slug: slug);
          if (value != null) {
            novel.value = Resource.data(value);
            break;
          }
        } catch (e, s) {
          print(e);
          print(s);
        }
      }
    }();

    return () {};
  }, []);

  return novel.value;
}
