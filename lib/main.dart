import "package:app/database/database_wrapper.dart";
import "package:app/downloads/downloads_manager.dart";
import "package:app/providers/async_provider.dart";
import "package:app/providers/database_provider.dart";
import "package:app/settings/settings.dart";
import "package:app/sources/database/chapter_dao.dart";
import "package:app/sources/database/novel_dao.dart";
import "package:app/ui/app.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:provider/provider.dart";

void main() {
  Main().run();
}

class Main extends HookWidget {
  void run() {
    runApp(this);
  }

  @override
  Widget build(BuildContext context) {
    return Settings(
      child: AsyncProvider<DatabaseWrapper>(
        create: (BuildContext context) {
          return newDatabase();
        },
        child: MultiProvider(
          providers: [
            Provider<NovelDao>(
              create: (BuildContext context) {
                return NovelDao(
                  Provider.of(context, listen: false),
                );
              },
            ),
            Provider<ChapterDao>(
              create: (BuildContext context) {
                return ChapterDao(
                  Provider.of(context, listen: false),
                  Provider.of(context, listen: false),
                );
              },
            ),
            Provider<DownloadsManager>(
              create: (BuildContext context) {
                return DownloadsManager(
                  chapterDao: Provider.of(context, listen: false),
                );
              },
            ),
          ],
          child: App(),
        ),
      ),
    );
  }
}
