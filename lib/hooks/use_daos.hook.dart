import "package:app/sources/database/chapter_dao.dart";
import "package:app/sources/database/novel_dao.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:provider/provider.dart";

NovelDao useNovelDao() {
  final context = useContext();
  return Provider.of(context);
}

ChapterDao useChapterDao() {
  final context = useContext();
  return Provider.of(context);
}
