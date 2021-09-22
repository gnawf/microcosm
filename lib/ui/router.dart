import "package:app/models/chapter.dart";
import "package:app/models/novel.dart";
import "package:app/navigation/fade_transition_route.dart";
import "package:app/ui/download_chapters_page.dart";
import "package:app/ui/downloaded_chapters_page.dart";
import "package:app/ui/downloaded_novels_page.dart";
import "package:app/ui/home_page.dart";
import "package:app/ui/novel_page.dart";
import "package:app/ui/opener_page.dart";
import "package:app/ui/reader_page.dart";
import "package:app/ui/recents_page.dart";
import "package:app/ui/search_page.dart";
import "package:app/ui/source_page.dart";
import "package:app/ui/sources_page.dart";
import "package:app/widgets/popup_settings.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:meta/meta.dart";

typedef AppRouteAction<R, T> = R Function(Route<T> route);

typedef AppRouteBuilder<T extends Route> = T Function(
  WidgetBuilder builder,
  RouteSettings settings,
);

Route _useCupertinoPageRoute(WidgetBuilder builder, RouteSettings settings) {
  return CupertinoPageRoute(builder: builder, settings: settings);
}

Route _useFadePageRoute(WidgetBuilder builder, RouteSettings settings) {
  return FadeTransitionPageRoute(builder: builder, settings: settings);
}

Route _useDialogPageRoute(WidgetBuilder builder, RouteSettings settings) {
  return RawDialogRoute(
    pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
      return builder(context);
    },
    settings: settings,
  );
}

@immutable
class _Routes<R> {
  const _Routes(this._action, [this._routeBuilder = _useCupertinoPageRoute]);

  final AppRouteAction _action;

  final AppRouteBuilder _routeBuilder;

  R _execute(WidgetBuilder builder, [RouteSettings settings]) {
    return _action(_routeBuilder(builder, settings));
  }

  _Routes<R> usePageRoute(AppRouteBuilder pageRouteBuilder) {
    return _Routes(_action, pageRouteBuilder);
  }

  _Routes<R> useCupertinoPageRoute() {
    return _Routes(_action, _useCupertinoPageRoute);
  }

  _Routes<R> useFadePageRoute() {
    return _Routes(_action, _useFadePageRoute);
  }

  _Routes<R> useDialogPageRoute() {
    return _Routes(_action, _useDialogPageRoute);
  }

  R home() {
    return _execute((BuildContext context) {
      return const HomePage();
    });
  }

  R recents() {
    return _execute((BuildContext context) {
      return const RecentsPage();
    }, const RouteSettings(name: "recents"));
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

  R opener() {
    return _execute((BuildContext context) {
      return const OpenerPage();
    });
  }

  R search({String sourceId}) {
    return _execute((BuildContext context) {
      return SearchPage(sourceId: sourceId);
    });
  }

  R settings() {
    return _execute((BuildContext context) {
      return PopupSettings();
    });
  }

  R downloadChapters({
    String novelSource,
    String novelSlug,
    Uri chapterUrl,
    Novel novel,
    Chapter chapter,
  }) {
    if (novel != null) {
      novelSource ??= novel.source;
      novelSlug ??= novel.slug;
    }
    if (chapter != null) {
      novelSource ??= chapter.novelSource;
      novelSlug ??= chapter.novelSlug;
      chapterUrl ??= chapter.url;
    }

    return _execute((context) {
      return DownloadChaptersPage(
        novelSource: novelSource,
        novelSlug: novelSlug,
        chapterUrl: chapterUrl,
      );
    });
  }

  R downloadedNovels() {
    return _execute((BuildContext context) {
      return DownloadedNovelsPage();
    });
  }

  R downloadedChapters(String novelSource, String novelSlug) {
    return _execute((BuildContext context) {
      return DownloadedChaptersPage(novelSource: novelSource, novelSlug: novelSlug);
    });
  }
}

/// Idiomatic API for pushing routes
///
/// e.g. AppRouter.of(context).push().homePage()
class AppRouter {
  AppRouter(this._navigator);

  factory AppRouter.from(NavigatorState navigator) {
    return navigator != null ? AppRouter(navigator) : null;
  }

  factory AppRouter.of(
    BuildContext context, {
    bool rootNavigator = false,
    bool nullOk = false,
  }) {
    final navigator = Navigator.of(context, rootNavigator: rootNavigator);
    return AppRouter.from(navigator);
  }

  final NavigatorState _navigator;

  static _Routes<T> routes<T extends Object>() {
    return _Routes((route) => route);
  }

  _Routes<Future<T>> push<T extends Object>() {
    return _Routes(_navigator.push);
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
