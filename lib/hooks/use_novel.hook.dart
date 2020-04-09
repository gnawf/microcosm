import "dart:async";

import "package:app/hooks/use_daos.hook.dart";
import "package:app/models/novel.dart";
import "package:app/resource/resource.dart";
import "package:app/resource/resource.hooks.dart";
import "package:app/sources/data.dart";
import "package:app/sources/database/novel_dao.dart";
import "package:app/sources/novel_source.dart";
import "package:app/sources/sources.dart";
import "package:flutter_hooks/flutter_hooks.dart";

typedef _SaveNovel = FutureOr<void> Function(Novel novel);

GetNovel _save(GetNovel fetcher, _SaveNovel save) {
  return ({String slug, Map<String, dynamic> params}) async {
    final novel = await fetcher(slug: slug);
    if (novel.data != null) {
      await save(novel.data);
    }
    return novel;
  };
}

Resource<Novel> useNovel(String source, String slug, {bool live = true}) {
  final dao = useNovelDao();
  final novelSource = getSource(id: source).novels;
  final novel = useResource<Novel>();

  useEffect(() {
    novel.value = const Resource.loading();

    () async {
      final _SaveNovel save = dao.upsert;

      for (final fetcher in <GetNovel>[
        _toGetNovel(dao, source),
        _save(novelSource.get, save),
      ]) {
        try {
          final value = await fetcher(slug: slug);
          if (value.data != null) {
            novel.value = Resource.data(value.data);
            // Don't fetch live data, be happy with the first result
            if (!live) {
              break;
            }
          }
        } catch (e, s) {
          print(e);
          print(s);
        }
      }
    }();

    return () {};
  }, [source, slug, live]);

  return novel.value;
}

GetNovel _toGetNovel(NovelDao dao, String source) {
  return ({String slug, Map<String, dynamic> params}) async {
    return Data(
      data: await dao.get(source: source, slug: slug),
    );
  };
}
