import "package:app/models/novel.dart";
import "package:app/providers/provider.hooks.dart";
import "package:app/resource/resource.dart";
import "package:app/resource/resource.hooks.dart";
import "package:flutter_hooks/flutter_hooks.dart";

Resource<Novel> useNovel(String source, String slug) {
  final novelProvider = useNovelProvider();
  final dao = novelProvider.dao;
  final novel = useResource<Novel>();

  useEffect(() {
    dao.get(source: source, slug: slug).then((value) {
      novel.value = Resource.data(value);
    }).catchError((error) {
      novel.value = Resource.error(error);
    });

    return () {};
  }, []);

  return novel.value;
}
