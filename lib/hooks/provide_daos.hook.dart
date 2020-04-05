import "package:app/providers/database_provider.dart";
import "package:app/sources/database/chapter_dao.dart";
import "package:app/sources/database/novel_dao.dart";
import "package:flutter/widgets.dart";
import "package:flutter_hooks/flutter_hooks.dart";

class ProvideDaosHook extends HookWidget {
  ProvideDaosHook._({
    Key key,
    @required this.novelDao,
    @required this.chapterDao,
    @required this.child,
  })  : assert(novelDao != null),
        assert(chapterDao != null),
        assert(child != null),
        super(key: key);

  factory ProvideDaosHook.use({@required Widget child}) {
    final context = useContext();
    final db = DatabaseProvider.of(context);
    final novelDao = useState<NovelDao>()..value ??= NovelDao(db.database);
    final chapterDao = useState<ChapterDao>()..value ??= ChapterDao(db.database, novelDao.value);

    return ProvideDaosHook._(
      novelDao: novelDao.value,
      chapterDao: chapterDao.value,
      child: child,
    );
  }

  final Widget child;

  final NovelDao novelDao;

  final ChapterDao chapterDao;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
