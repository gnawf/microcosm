import "package:app/hooks/provide_daos.hook.dart";
import "package:app/sources/database/chapter_dao.dart";
import "package:app/sources/database/novel_dao.dart";
import "package:flutter_hooks/flutter_hooks.dart";

ProvideDaosHook _useDaos() {
  final context = useContext();
  return context.findAncestorWidgetOfExactType<ProvideDaosHook>();
}

NovelDao useNovelDao() {
  return _useDaos().novelDao;
}

ChapterDao useChapterDao() {
  return _useDaos().chapterDao;
}
