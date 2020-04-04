import "dart:async";

import "package:app/models/chapter.dart";
import "package:app/providers/provider.hooks.dart";
import "package:app/resource/resource.dart";
import "package:app/resource/resource.hooks.dart";
import "package:app/sources/chapter_source.dart";
import "package:app/sources/data.dart";
import "package:app/sources/database/chapter_dao.dart";
import "package:flutter_hooks/flutter_hooks.dart";

Resource<Chapter> useChapter(Uri url) {
  // State
  final currentLoadId = useState(0);
  final refreshRequest = useState<Completer>(null);
  final chapter = useResource<Chapter>();

  // Get sources
  final chapters = useChapterProvider();
  final dao = useChapterDao();
  final upstream = chapters.source(url: url);

  // Fetches the chapter and updates the relevant state hooks
  Future<void> fetch(List<GetChapter> sources) async {
    final loadId = ++currentLoadId.value;
    final value = await _fetch(url, sources);
    if (loadId != currentLoadId.value) {
      return;
    }
    chapter.value = Resource.data(value.data, onRefresh: () {
      // Set the refresh request and then wait on its future
      return (refreshRequest.value = Completer()).future;
    });
  }

  // Initial load
  useEffect(() {
    chapter.value = const Resource.loading();
    fetch([_toGetChapter(dao), upstream.get]);
    return () {};
  }, [url]);

  // Fulfill refresh requests
  useEffect(() {
    final ourRefresh = refreshRequest.value;
    if (ourRefresh != null) {
      fetch([upstream.get, _toGetChapter(dao)]).then((value) => ourRefresh.complete());
    }
    return () {};
  }, [refreshRequest.value]);

  return chapter.value;
}

Future<Data<Chapter>> _fetch(Uri url, List<GetChapter> fetchers) async {
  for (final fetcher in fetchers) {
    try {
      final result = await fetcher(url: url);
      if (result.data != null) {
        return result;
      }
    } catch (e, s) {
      print(e);
      print(s);
    }
  }

  return null;
}

GetChapter _toGetChapter(ChapterDao dao) {
  return ({Uri url, Map<String, dynamic> params}) async {
    return Data(
      data: await dao.get(url: url),
    );
  };
}
