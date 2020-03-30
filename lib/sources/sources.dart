import "package:app/sources/read_novel_full/read_novel_full.dart";
import 'package:app/sources/source.dart';
import "package:app/sources/volare/volare.dart";
import "package:app/sources/wuxia_world/wuxia_world.dart";

final _sources = [
  WuxiaWorld(),
  Volare(),
  ReadNovelFull(),
];

Source useSource(String id) {
  return _sources.firstWhere((element) => element.id == id);
}

List<Source> useSources() {
  return _sources;
}
