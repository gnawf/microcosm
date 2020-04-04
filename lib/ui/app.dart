import "package:app/settings/settings.dart";
import "package:app/ui/router.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

class App extends StatefulWidget {
  const App();

  @override
  State createState() => _AppState();
}

class _AppState extends State<App> {
  SettingsState _settings;

  void _invalidate() {
    setState(() {});
  }

  Route _router(RouteSettings route) {
    assert(route.name == "/");
    return Router.routes().home();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settings = Settings.of(context);
    _settings.primarySwatchChanges.addListener(_invalidate);
    _settings.accentColorChanges.addListener(_invalidate);
    _settings.brightnessChanges.addListener(_invalidate);
    _settings.amoledChanges.addListener(_invalidate);
  }

  @override
  void deactivate() {
    _settings.primarySwatchChanges.removeListener(_invalidate);
    _settings.accentColorChanges.removeListener(_invalidate);
    _settings.brightnessChanges.removeListener(_invalidate);
    _settings.amoledChanges.removeListener(_invalidate);
    _settings = null;
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final amoled = _settings.brightness == Brightness.dark && _settings.amoled;

    return MaterialApp(
      title: "Microcosm",
      theme: ThemeData(
        primarySwatch: _settings.primarySwatch,
        primaryColor: _settings.primarySwatch,
        primaryColorLight: _settings.primarySwatch[100],
        primaryColorDark: _settings.primarySwatch[700],
        accentColor: _settings.accentColor,
        brightness: _settings.brightness,
        canvasColor: amoled ? Colors.black : null,
        typography: Typography.material2018(platform: defaultTargetPlatform),
      ),
      onGenerateRoute: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
