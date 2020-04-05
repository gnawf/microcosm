import "package:app/hooks/use_chapter.hook.dart";
import "package:app/hooks/use_theme.hook.dart";
import "package:app/models/chapter.dart";
import "package:app/resource/resource.dart";
import "package:app/resource/resource.hooks.dart";
import "package:app/sources/sources.dart";
import "package:app/ui/router.dart";
import "package:app/ui/router.hooks.dart";
import "package:app/widgets/settings_icon_button.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

part "download_chapters_page.hooks.dart";

class DownloadChaptersPage extends HookWidget {
  const DownloadChaptersPage({
    Key key,
    @required this.novelSource,
    @required this.novelSlug,
    @required this.chapterUrl,
  })  : assert(novelSource != null),
        assert(novelSlug != null),
        super(key: key);

  final String novelSource;

  final String novelSlug;

  final Uri chapterUrl;

  @override
  Widget build(BuildContext context) {
    return _PageState.use(
      parent: this,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Download"),
          centerTitle: false,
          actions: const <Widget>[
            SettingsIconButton(),
          ],
        ),
        body: _Body(),
      ),
    );
  }
}

class _PageState extends StatelessWidget {
  const _PageState._({
    Key key,
    @required this.anchorChapter,
    @required Router router,
    @required this.child,
  })  : _router = router,
        super(key: key);

  factory _PageState.use({
    Key key,
    @required DownloadChaptersPage parent,
    @required Widget child,
  }) {
    assert(child != null);

    final chapter = useChapter(parent.chapterUrl);
    final referenceChapter = useResource<Chapter>();
    final router = useRouter();

    useEffect(() {
      referenceChapter.value = chapter;
      return () {};
    }, [chapter]);

    return _PageState._(
      key: key,
      anchorChapter: referenceChapter,
      router: router,
      child: child,
    );
  }

  final Widget child;

  final ValueNotifier<Resource<Chapter>> anchorChapter;

  final Router _router;

  void download(int next) {
    _router.pop();
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class _Body extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final state = _usePageState();
    final anchorChapter = state.anchorChapter.value;

    switch (anchorChapter.state) {
      case ResourceState.placeholder:
        return const SizedBox.shrink();
      case ResourceState.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case ResourceState.done:
        if (anchorChapter.data == null) {
          return const Center(
            child: Text("Unable to grab anchor chapter"),
          );
        }
        break;
      case ResourceState.error:
        return Center(
          child: Text("${anchorChapter.error}"),
        );
    }

    return _DownloadActions();
  }
}

class _DownloadActions extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final state = _usePageState();
    final anchor = state.anchorChapter.value.data;
    final source = useSource(id: anchor.novelSource);
    final theme = useTheme();
    final actionsEnabled = false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.only(
            left: 24.0,
            top: 8.0,
          ),
          title: Text("From ${anchor.title}"),
          subtitle: Text(source.name),
        ),
        const Divider(),
        ListTile(
          contentPadding: const EdgeInsets.only(
            left: 24.0,
            right: 8.0,
          ),
          onTap: () => state.download(10),
          title: const Text("Download next 10 chapters"),
          enabled: actionsEnabled,
        ),
        ListTile(
          contentPadding: const EdgeInsets.only(
            left: 24.0,
            right: 8.0,
          ),
          onTap: () => state.download(50),
          title: const Text("Download next 50 chapters"),
          enabled: actionsEnabled,
        ),
        ListTile(
          contentPadding: const EdgeInsets.only(
            left: 24.0,
            right: 8.0,
          ),
          onTap: () => state.download(100),
          title: const Text("Download next 100 chapters"),
          enabled: actionsEnabled,
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.only(
            left: 24.0,
            top: 12.0,
            right: 8.0,
          ),
          child: Text(
            "Note downloads are subject to availability",
            style: theme.textTheme.caption,
          ),
        ),
      ],
    );
  }
}
