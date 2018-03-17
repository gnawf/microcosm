import "dart:async";

import "package:app/ui/routes.dart" as routes;
import "package:app/widgets/md_icons.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  State createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _navigatorKey = new GlobalKey<NavigatorState>();

  final _indices = <int>[];

  List<BottomNavigationBarItem> _bottomBarItems;

  HeroController _heroController;

  RectTween _createRectTween(Rect begin, Rect end) {
    return new MaterialRectArcTween(begin: begin, end: end);
  }

  Route _router(RouteSettings settings) {
    // Just return the route for the current index
    return _route(_indices.last);
  }

  Route _route(int index) {
    if (!mounted) {
      return null;
    }

    switch (index) {
      case 0:
        return routes.browse();
      case 1:
        return routes.opener();
      case 2:
        return routes.recents();
      case 3:
        return routes.downloads();
    }

    return null;
  }

  Future<Null> _pushPage(int index) async {
    if (!mounted) {
      return;
    }

    final route = _route(index);

    if (route == null) {
      return;
    }

    // Handle case where there's no back button
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (_indices.last == index) {
        // Go back instead of replacing if the requested view is in the stack
        _navigatorKey.currentState?.popUntil((r) => r.isFirst);
      } else {
        // Clear the navigation stack & push the requested view
        setState(() => _indices[0] = index);
        _navigatorKey.currentState?.pushAndRemoveUntil(route, (r) => false);
      }
      return;
    }

    // Push to the stack queue
    setState(() => _indices.add(index));
    // Push if applicable
    await _navigatorKey.currentState?.push(route);
    // Pop off the indices stack once the view is disposed of
    if (mounted) {
      setState(() => _indices.removeLast());
    }
  }

  @override
  void initState() {
    super.initState();

    // Setup bottom navigation bar items
    _bottomBarItems = const <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: const Icon(MDIcons.magnify),
        title: const Text("Browse"),
      ),
      const BottomNavigationBarItem(
        icon: const Icon(MDIcons.linkVariant),
        title: const Text("Open"),
      ),
      const BottomNavigationBarItem(
        icon: const Icon(MDIcons.history),
        title: const Text("Recents"),
      ),
      const BottomNavigationBarItem(
        icon: const Icon(MDIcons.download),
        title: const Text("Saved"),
      ),
    ];

    // Set initial page
    _indices.add(0);

    _heroController = new HeroController(createRectTween: _createRectTween);
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      // Pop the internal navigator first
      onWillPop: () async => !_navigatorKey.currentState.pop(),
      child: new Scaffold(
        // Internal navigator for bottom navigation
        body: new Navigator(
          key: _navigatorKey,
          initialRoute: "/",
          onGenerateRoute: _router,
          observers: <NavigatorObserver>[_heroController],
        ),
        bottomNavigationBar: new BottomNavigationBar(
          onTap: _pushPage,
          currentIndex: _indices.last,
          items: _bottomBarItems,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
