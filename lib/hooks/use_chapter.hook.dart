import "dart:async";

import "package:app/hooks/use_daos.hook.dart";
import "package:app/models/chapter.dart";
import "package:app/resource/resource.dart";
import "package:app/resource/resource.hooks.dart";
import "package:app/sources/chapter_source.dart";
import "package:app/sources/data.dart";
import "package:app/sources/database/chapter_dao.dart";
import "package:app/sources/sources.dart";
import "package:flutter_hooks/flutter_hooks.dart";

Resource<Chapter> useChapter(Uri url) {
  // State
  final currentLoadId = useState(0);
  final refreshRequest = useState<Completer>(null);
  final chapter = useResource<Chapter>();

  // Get sources
  final dao = useChapterDao();
  final daoFetcher = (useState<GetChapter>()..value ??= _toGetChapter(dao)).value;
  final upstreamFetcher = _save(useSource(url: url)?.chapters?.get, dao);

  // Fetches the chapter and updates the relevant state hooks
  Future<void> stateAwareFetch(List<GetChapter> sources) async {
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
    if (url != null) {
      chapter.value = const Resource.loading();
      stateAwareFetch([daoFetcher, upstreamFetcher]);
    }
    return () {};
  }, [url]);

  // Fulfill refresh requests
  useEffect(() {
    if (url != null) {
      final ourRefresh = refreshRequest.value;
      if (ourRefresh != null) {
        stateAwareFetch([upstreamFetcher, daoFetcher]).then((value) {
          ourRefresh.complete();
        });
      }
    }
    return () {};
  }, [refreshRequest.value]);

  return chapter.value;
}

Future<Data<Chapter>> _fetch(Uri url, List<GetChapter> fetchers) async {
  for (final fetcher in fetchers) {
    if (fetcher == null) {
      continue;
    }

    try {
      final result = await fetcher(url: url);
      if (result.data != null) {
        return result;
      }
    } on Error catch (e, s) {
      print(e);
      print(s);
    }
  }

  return null;
}

GetChapter _save(GetChapter fetcher, ChapterDao dao) {
  return ({Uri url, Map<String, dynamic> params}) async {
    final result = await fetcher(url: url, params: params);
    if (result.data != null) {
      dao.upsert(result.data);
    }
    return result;
  };
}

GetChapter _toGetChapter(ChapterDao dao) {
  return ({Uri url, Map<String, dynamic> params}) async {
    return Data(
      data: await dao.get(url: url),
    );
  };
}
