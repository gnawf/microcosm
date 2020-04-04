import "package:app/providers/database_provider.dart";
import "package:app/sources/database/novel_dao.dart";
import "package:flutter/material.dart";
import "package:meta/meta.dart";

class NovelProvider extends StatefulWidget {
  const NovelProvider({@required this.child});

  final Widget child;

  @deprecated
  static NovelProviderState of(BuildContext context) {
    return context.findAncestorStateOfType<NovelProviderState>();
  }

  @override
  State createState() => NovelProviderState();
}

class NovelProviderState extends State<NovelProvider> {
  NovelDao _novelDao;

  NovelDao get dao => _novelDao;

  @override
  void initState() {
    super.initState();

    final databases = DatabaseProvider.of(context);
    _novelDao = NovelDao(databases.database);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
