import "package:app/hooks/provide_daos.hook.dart";
import "package:app/providers/database_provider.dart";
import "package:app/settings/settings.dart";
import "package:app/ui/app.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

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
      child: DatabaseProvider(
        child: DatabaseAwareMain(),
      ),
    );
  }
}

class DatabaseAwareMain extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return ProvideDaosHook.use(
      child: App(),
    );
  }
}
