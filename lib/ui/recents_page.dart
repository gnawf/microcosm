import "package:app/hooks/use_daos.hook.dart";
import "package:app/hooks/use_is_disposed.hook.dart";
import "package:app/hooks/use_navigator_observers.dart";
import "package:app/hooks/use_novel.hook.dart";
import "package:app/models/chapter.dart";
import "package:app/navigation/on_navigate.dart";
import "package:app/resource/resource.dart";
import "package:app/resource/resource.hooks.dart";
import "package:app/sources/database/chapter_dao.dart";
import "package:app/sources/sources.dart";
import "package:app/ui/router.hooks.dart";
import "package:app/widgets/image_view.dart";
import "package:app/widgets/resource_builder.dart";
import "package:app/widgets/settings_icon_button.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

part "recents_page.hooks.dart";

class RecentsPage extends HookWidget {
  const RecentsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _PageState.create(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: null,
          title: const Text("Recently Read"),
          centerTitle: false,
          actions: const [
            SettingsIconButton(),
          ],
        ),
        body: _Body(),
      ),
    );
  }
}

class _PageState extends HookWidget {
  _PageState._({
    @required this.recents,
    @required this.child,
  })  : assert(recents != null),
        assert(child != null);

  factory _PageState.create({@required Widget child}) {
    final recents = _useRecents();

    return _PageState._(
      recents: recents,
      child: child,
    );
  }

  final Resource<List<Chapter>> recents;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class _Body extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final pageState = _usePageState();
    final observer = useState<NavigatorObserver>(null);

    useEffect(() {
      observer.value = OnNavigate(onPop: (route, prevRoute) {
        if (prevRoute.settings.name == "recents") {
          pageState.recents.refresh();
        }
      });

      return () {};
    }, [pageState.recents]);

    useNavigatorObserver(observer.value);

    return _RecentsList();
  }
}

class _RecentsList extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final pageState = _usePageState();
    final recentsResource = pageState.recents;

    return ResourceBuilder(
      resource: recentsResource,
      doneBuilder: (BuildContext context, Resource<List<Chapter>> resource) {
        final chapters = resource.data;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
          ),
          itemBuilder: (BuildContext context, int index) {
            return _RecentsListEntry(chapters[index]);
          },
          itemCount: chapters.length,
        );
      },
    );
  }
}

class _RecentsListEntry extends HookWidget {
  const _RecentsListEntry(this.chapter);

  final Chapter chapter;

  @override
  Widget build(BuildContext context) {
    final chapterResource = _useChapter(chapter);
    final onTap = _useOpenRecent(chapter);

    return ResourceBuilder(
      resource: chapterResource,
      loadingBuilder: _loadingBuilder,
      doneBuilder: (BuildContext context, Resource<Chapter> resource) {
        final chapter = resource.data;
        final novel = chapter.novel;
        final novelName = novel?.name ?? chapter.novelSlug ?? "Unknown";
        final source = getSource(id: chapterResource.data?.novelSource);

        return ListTile(
          onTap: onTap,
          leading: Container(
            constraints: const BoxConstraints(
              maxWidth: 40.0,
              maxHeight: 60.0,
            ),
            child: ImageView(
              image: novel?.posterImage,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(chapter.title),
          subtitle: Text("$novelName from ${source.name}"),
        );
      },
      errorBuilder: _errorBuilder,
    );
  }

  static Widget _loadingBuilder(BuildContext context) {
    return const ListTile(
      leading: CircularProgressIndicator(),
      title: Text("Loading"),
    );
  }

  static Widget _errorBuilder(BuildContext context, Resource<Chapter> resource) {
    return ListTile(
      title: const Text("An Error Ocurred"),
      subtitle: Text("${resource.error}"),
    );
  }
}
