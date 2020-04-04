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

Source useSource(String id) {
  return _sourcesMap[id];
}

List<Source> useSources() {
  return _sources;
}

Map<String, Source> _toMap() {
  final map = <String, Source>{};
  for (final value in _sources) {
    map[value.id] = value;
  }
  return map;
}
