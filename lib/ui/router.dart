import "package:app/models/novel.dart";
import "package:app/navigation/fade_transition_route.dart";
import "package:app/navigation/transitions.dart";
import "package:app/ui/downloads_page.dart";
import "package:app/ui/home_page.dart";
import "package:app/ui/novel_page.dart";
import "package:app/ui/opener_page.dart";
import "package:app/ui/reader_page.dart";
import "package:app/ui/recents_page.dart";
import "package:app/ui/settings_page.dart";
import "package:app/ui/source_page.dart";
import "package:app/ui/sources_page.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:meta/meta.dart";

typedef RouteAction<R, T> = R Function(Route<T> route);

typedef RouteBuilder<T extends Route> = T Function(
  WidgetBuilder builder,
);

Route _useCupertinoPageRoute(WidgetBuilder builder) {
  return CupertinoPageRoute(builder: builder);
}

Route _useFadePageRoute(WidgetBuilder builder) {
  return FadeTransitionPageRoute(builder: builder);
}

@immutable
class _Routes<R> {
  const _Routes(this._action, [this._routeBuilder = _useFadePageRoute]);

  final RouteAction _action;

  final RouteBuilder _routeBuilder;

  R _execute(WidgetBuilder builder) {
    return _action(_routeBuilder(builder));
  }

  _Routes<R> usePageRoute(RouteBuilder pageRouteBuilder) {
    return _Routes(_action, pageRouteBuilder);
  }

  _Routes<R> useCupertinoPageRoute() {
    return _Routes(_action, _useCupertinoPageRoute);
  }

  _Routes<R> useFadePageRoute() {
    return _Routes(_action, _useFadePageRoute);
  }

  R home() {
    return _execute((BuildContext context) {
      return const HomePage();
    });
  }

  R recents() {
    return _execute((BuildContext context) {
      return const RecentsPage();
    });
  }

  R reader({@required Uri url}) {
    return _execute((BuildContext context) {
      return ReaderPage(url);
    });
  }

  R novel({Novel novel, String source, String slug}) {
    source ??= novel.source;
    slug ??= novel.slug;

    return _execute((BuildContext context) {
      return NovelPage(source: source, slug: slug);
    });
  }

  R browse({Uri url}) {
    return _execute((BuildContext context) {
      return const SourcesPage();
    });
  }

  R source({@required String sourceId}) {
    return _execute((BuildContext context) {
      return SourcePage(sourceId: sourceId);
    });
  }

  R downloads({
    String novelSource,
    String novelSlug,
    Novel novel,
  }) {
    novelSource ??= novel?.source;
    novelSlug ??= novel?.slug;

    return _execute((BuildContext context) {
      return DownloadsPage(novelSource: novelSource, novelSlug: novelSlug);
    });
  }

  R opener() {
    return _execute((BuildContext context) {
      return const OpenerPage();
    });
  }

  R settings() {
    return _execute((BuildContext context) {
      return SettingsPage();
    });
  }
}

/// Idiomatic API for pushing routes
///
/// e.g. Router.of(context).push().homePage()
class Router {
  Router.of(
    this.context, {
    this.rootNavigator = false,
    this.nullOk = false,
  });

  final BuildContext context;

  final bool rootNavigator;

  final bool nullOk;

  NavigatorState get _navigator => Navigator.of(
        context,
        rootNavigator: rootNavigator,
        nullOk: nullOk,
      );

  static _Routes<T> routes<T extends Object>() {
    return _Routes((route) => route);
  }

  _Routes<Future<T>> push<T extends Object>() {
    return _Routes((route) {
      return _navigator.push(route);
    });
  }

  _Routes<Future<T>> pushReplacement<T extends Object, TO extends Object>({
    TO result,
  }) {
    return _Routes((route) {
      return _navigator.pushReplacement(route, result: result);
    });
  }

  _Routes<Future<T>> pushAndRemoveUntil<T extends Object>(
    RoutePredicate predicate,
  ) {
    return _Routes((route) {
      return _navigator.pushAndRemoveUntil(route, predicate);
    });
  }

  void pop<T extends Object>([T result]) {
    _navigator.pop(result);
  }
}
