import "package:app/providers/chapter_provider.dart";
import "package:app/providers/database_provider.dart";
import "package:app/providers/novel_provider.dart";
import "package:app/sources/database/chapter_dao.dart";
import "package:app/sources/database/novel_dao.dart";
import "package:flutter_hooks/flutter_hooks.dart";

NovelProviderState useNovelProvider() {
  final context = useContext();
  return NovelProvider.of(context);
}

NovelDao useNovelDao() {
  return useNovelProvider().dao;
}

DatabaseProviderState useDatabaseProvider() {
  final context = useContext();
  return DatabaseProvider.of(context);
}

ChapterProviderState useChapterProvider() {
  final context = useContext();
  return ChapterProvider.of(context);
}

ChapterDao useChapterDao() {
  return useChapterProvider().dao;
}
