import "dart:async";

import "package:app/models/chapter.dart";
import "package:app/providers/chapter_provider.dart";
import "package:app/resource/resource.dart";
import "package:app/resource/resource.hooks.dart";
import "package:app/sources/chapter_source.dart";
import "package:flutter_hooks/flutter_hooks.dart";

Resource<Chapter> useChapter(Uri url) {
  final context = useContext();

  // State
  final currentLoadId = useState(0);
  final refreshRequest = useState<Completer>(null);
  final chapter = useResource<Chapter>();

  // Get sources
  final chapters = ChapterProvider.of(context);
  final dao = chapters.dao;
  final upstream = chapters.source(url: url);

  // Fetches the chapter and updates the relevant state hooks
  Future<void> fetch(List<ChapterSource> sources) async {
    final loadId = ++currentLoadId.value;
    final value = await _fetch(url, sources);
    if (loadId != currentLoadId.value) {
      return;
    }
    chapter.value = Resource.data(value, onRefresh: () {
      // Set the refresh request and then wait on its future
      return (refreshRequest.value = new Completer()).future;
    });
  }

  // Initial load
  useEffect(() {
    chapter.value = const Resource.loading();
    fetch([dao, upstream]);
    return () {};
  }, [url]);

  // Fulfill refresh requests
  useEffect(() {
    final ourRefresh = refreshRequest.value;
    if (ourRefresh != null) {
      fetch([upstream, dao]).then((value) => ourRefresh.complete());
    }
    return () {};
  }, [refreshRequest.value]);

  return chapter.value;
}

Future<Chapter> _fetch(Uri url, List<ChapterSource> sources) async {
  for (final source in sources) {
    try {
      final result = await source.get(url: url);
      if (result != null) {
        return result;
      }
    } catch (e, s) {
      print(e);
      print(s);
    }
  }

  return null;
}
