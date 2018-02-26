import "package:app/settings/settings.dart";
import "package:app/ui/routes.dart" as routes;
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

class App extends StatefulWidget {
  const App();

  @override
  State createState() => new _AppState();
}

class _AppState extends State<App> {
  VoidCallback _dispose;

  void _invalidate() {
    setState(() {});
  }

  Route _router(RouteSettings route) {
    return route.name == "/" ? routes.home() : null;
  }

  @override
  void initState() {
    super.initState();

    final settings = Settings.of(context);
    settings.primarySwatchChanges.addListener(_invalidate);
    settings.accentColorChanges.addListener(_invalidate);
    settings.brightnessChanges.addListener(_invalidate);
    settings.amoledChanges.addListener(_invalidate);
    // Setup destroy
    _dispose = () {
      settings.primarySwatchChanges.removeListener(_invalidate);
      settings.accentColorChanges.removeListener(_invalidate);
      settings.brightnessChanges.removeListener(_invalidate);
      settings.amoledChanges.removeListener(_invalidate);
    };
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Settings.of(context);

    final platform = defaultTargetPlatform;
    final iOS = TargetPlatform.iOS;

    final canvasColor =
        settings.brightness == Brightness.dark && settings.amoled
            ? Colors.black
            : null;

    return new MaterialApp(
      title: "Microcosm",
      theme: new ThemeData(
        primarySwatch: settings.primarySwatch,
        accentColor: settings.accentColor,
        brightness: settings.brightness,
        canvasColor: canvasColor,
        fontFamily: platform != iOS ? "Open Sans" : null,
      ),
      onGenerateRoute: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
