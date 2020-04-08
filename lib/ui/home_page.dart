import "dart:async";

import "package:app/settings/settings.dart";
import "package:app/ui/router.dart";
import "package:app/widgets/md_icons.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  final _indices = <int>[];

  List<BottomNavigationBarItem> _bottomBarItems;

  HeroController _heroController;

  RectTween _createRectTween(Rect begin, Rect end) {
    return MaterialRectArcTween(begin: begin, end: end);
  }

  Route _router(RouteSettings settings) {
    // Just return the route for the current index
    return _route(_indices.last);
  }

  Route _route(int index) {
    if (!mounted) {
      return null;
    }

    final routes = Router.routes();

    switch (index) {
      case 0:
        return routes.browse();
      case 1:
        return routes.opener();
      case 2:
        return routes.recents();
      case 3:
        return routes.downloadedNovels();
    }

    return null;
  }

  Future<void> _pushPage(int index) async {
    if (!mounted) {
      return;
    }

    final route = _route(index);

    if (route == null) {
      return;
    }

    // Handle case where there's no back button
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      _navigatorKey.currentState?.popUntil((r) => r.isFirst);
      if (_indices.first != index) {
        // Clear the navigation stack & push the requested view
        setState(() => _indices
          ..clear()
          ..add(index));
        _navigatorKey.currentState?.pushReplacement(route);
      }
      return;
    }

    // Push to the stack
    setState(() => _indices.add(index));
    // Wait for the view to be popped off the stack
    await _navigatorKey.currentState?.push(route);
    // Pop off the indices stack once the view is disposed of
    if (mounted) {
      setState(_indices.removeLast);
    }
  }

  @override
  void initState() {
    super.initState();

    // Setup bottom navigation bar items
    _bottomBarItems = const [
      BottomNavigationBarItem(
        icon: Icon(MDIcons.magnify),
        title: Text("Browse"),
      ),
      BottomNavigationBarItem(
        icon: Icon(MDIcons.linkVariant),
        title: Text("Open"),
      ),
      BottomNavigationBarItem(
        icon: Icon(MDIcons.history),
        title: Text("Recents"),
      ),
      BottomNavigationBarItem(
        icon: Icon(MDIcons.download),
        title: Text("Downloads"),
      ),
    ];

    _heroController = HeroController(createRectTween: _createRectTween);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Settings.of(context);

    if (_indices.isEmpty) {
      // Note: the LandingPage indices currently maps to the bottom bar page indices
      // But there is no guarantee that this will be the case in the future
      _indices.add(settings.landingPage.index);
    }

    return WillPopScope(
      // Pop the internal navigator first
      onWillPop: () async {
        final navigator = _navigatorKey.currentState;
        final canPop = navigator.canPop();
        if (canPop) {
          navigator.pop();
        }
        return !canPop;
      },
      child: Scaffold(
        // Internal navigator for bottom navigation
        body: Navigator(
          key: _navigatorKey,
          initialRoute: "/",
          onGenerateRoute: _router,
          observers: <NavigatorObserver>[_heroController],
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: _pushPage,
          currentIndex: _indices.last,
          items: _bottomBarItems,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
