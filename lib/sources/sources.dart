import "package:app/sources/read_novel_full/read_novel_full.dart";
import "package:app/sources/source.dart";
import "package:app/sources/volare/volare.dart";
import "package:app/sources/wuxia_world/wuxia_world.dart";

final _sources = [
  WuxiaWorld(),
  Volare(),
  ReadNovelFull(),
];

final _sourcesMap = _toMap();

Source useSource({String id, String host, Uri url}) {
  host ??= url?.host;
  return _sourcesMap[_key(id: id, host: host)];
}

List<Source> useSources() {
  return _sources;
}

Map<String, Source> _toMap() {
  final map = <String, Source>{};
  for (final source in _sources) {
    final idKey = _key(id: source.id);
    assert(!map.containsKey(idKey), "No two sources can share the same id: ${source.id}");
    map[idKey] = source;
    for (final host in source.hosts) {
      final hostKey = _key(host: host);
      assert(!map.containsKey(hostKey), "No two sources can support the same host: $host");
      map[hostKey] = source;
    }
  }
  return map;
}

String _key({String id, String host}) {
  assert(id == null || host == null, "Can only generate key for one property at a time");
  return id != null ? "id.$id" : host != null ? "host.$host" : null;
}
