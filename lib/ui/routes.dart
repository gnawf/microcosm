import "package:app/models/chapter.dart";
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
import "package:meta/meta.dart";

enum RouteType {
  slide,
  fade,
}

Route _route({
  @required RouteSettings settings,
  @required WidgetBuilder builder,
  RouteType type,
}) {
  type ??= RouteType.fade;

  switch (type) {
    case RouteType.slide:
      return CupertinoPageRoute(settings: settings, builder: builder);
    case RouteType.fade:
      return FadeTransitionPageRoute(settings: settings, builder: builder);
  }

  throw UnsupportedError("no-op");
}

Route home({RouteType type}) {
  return _route(
    settings: const RouteSettings(name: "home"),
    builder: (BuildContext context) => const HomePage(),
    type: type,
  );
}

Route recents({RouteType type}) {
  return _route(
    settings: const RouteSettings(name: "recents"),
    builder: (BuildContext context) => const RecentsPage(),
    type: type,
  );
}

Route reader({RouteType type, @required Uri url}) {
  final slug = slugify(uri: url);

  return _route(
    settings: RouteSettings(name: "reader/$slug"),
    builder: (BuildContext context) => ReaderPage(url),
    type: type,
  );
}

Route novel({RouteType type, Novel novel, String source, String slug}) {
  source ??= novel.source;
  slug ??= novel.slug;

  return _route(
    settings: RouteSettings(name: "novel/$source/$slug"),
    builder: (BuildContext context) => NovelPage(source: source, slug: slug),
    type: type,
  );
}

Route browse({RouteType type, Uri url}) {
  return _route(
    settings: const RouteSettings(name: "browse"),
    builder: (BuildContext context) => const SourcesPage(),
    type: type,
  );
}

Route source({RouteType type, @required String sourceId}) {
  return _route(
    settings: RouteSettings(name: "source/$sourceId"),
    builder: (BuildContext context) => SourcePage(sourceId: sourceId),
    type: type,
  );
}

Route downloads({RouteType type, String novelSource, String novelSlug}) {
  return _route(
    settings: RouteSettings(name: "downloads/$novelSource/$novelSlug"),
    builder: (BuildContext context) =>
        DownloadsPage(novelSource: novelSource, novelSlug: novelSlug),
    type: type,
  );
}

Route opener({RouteType type}) {
  return _route(
    settings: const RouteSettings(name: "opener"),
    builder: (BuildContext context) => const OpenerPage(),
    type: type,
  );
}

Route settings({RouteType type}) {
  return _route(
    settings: const RouteSettings(name: "settings"),
    builder: (BuildContext context) => SettingsPage(),
    type: type,
  );
}
