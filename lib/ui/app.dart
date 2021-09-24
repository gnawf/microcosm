import "package:app/settings/settings.dart";
import "package:app/ui/router.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

Route _router(RouteSettings route) {
  assert(route.name == "/");
  return AppRouter.routes().home();
}

class App extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Settings.of(context);
    useListenable(settings.primarySwatchChanges);
    useListenable(settings.accentColorChanges);
    useListenable(settings.brightnessChanges);
    useListenable(settings.amoledChanges);
    final amoled = settings.brightness == Brightness.dark && settings.amoled;

    return MaterialApp(
      title: "Microcosm",
      theme: ThemeData(
        primaryColor: settings.primarySwatch,
        primaryColorLight: settings.primarySwatch[100],
        primaryColorDark: settings.primarySwatch[700],
        brightness: settings.brightness,
        canvasColor: amoled ? Colors.black : null,
        typography: Typography.material2018(
          platform: defaultTargetPlatform,
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: settings.primarySwatch,
          brightness: settings.brightness,
        ).copyWith(
          secondary: settings.accentColor,
        ),
      ),
      onGenerateRoute: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
