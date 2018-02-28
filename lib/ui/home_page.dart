import "dart:async";

import "package:app/settings/settings.dart";
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

  Route _router(RouteSettings settings) {
    // Just return the route for the current index
    return _route(_indices.last);
  }

  Route _route(int index) {
    if (!mounted) {
      return null;
    }

    final settings = Settings.of(context);

    switch (index) {
      case 0:
        return routes.recents();
      case 1:
        return routes.recents();
      case 2:
        final chapterUrl = Uri.parse(settings.lastChapterUrl);
        return routes.reader(url: chapterUrl);
    }

    return null;
  }

  Future<Null> _pushPage(int index) async {
    if (!mounted) {
      return;
    }

    if (_indices.last == index) {
      _navigatorKey.currentState?.popUntil((r) => r.isFirst);
      return;
    }

    final route = _route(index);

    if (route == null) {
      return;
    }

    // If there's no back button just replace the view
    if (defaultTargetPlatform != TargetPlatform.android) {
      setState(() => _indices[0] = index);
      _navigatorKey.currentState?.pushReplacement(route);
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
    _bottomBarItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: const Icon(MDIcons.magnify),
        title: const Text("Browse"),
      ),
      const BottomNavigationBarItem(
        icon: const Icon(MDIcons.history),
        title: const Text("Recents"),
      ),
      const BottomNavigationBarItem(
        icon: const Icon(MDIcons.download),
        title: const Text("Downloads"),
      ),
    ];

    // Set initial page
    _indices.add(0);
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
        ),
        bottomNavigationBar: new BottomNavigationBar(
          onTap: _pushPage,
          currentIndex: _indices.last,
          items: _bottomBarItems,
        ),
      ),
    );
  }
}
