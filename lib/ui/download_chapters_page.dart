import "dart:async";

import "package:app/downloads/downloads_manager.dart";
import "package:app/hooks/use_chapter.hook.dart";
import "package:app/hooks/use_chapters.hook.dart";
import "package:app/hooks/use_downloads_manager.hook.dart";
import "package:app/hooks/use_theme.hook.dart";
import "package:app/models/chapter.dart";
import "package:app/resource/paginated_resource.dart";
import "package:app/resource/resource.dart";
import "package:app/resource/resource.hooks.dart";
import "package:app/sources/sources.dart";
import "package:app/ui/router.hooks.dart";
import "package:app/widgets/resource_builder.dart";
import "package:app/widgets/settings_icon_button.dart";
import "package:flutter/foundation.dart";
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
    @required this.numToDownload,
    @required this.chapters,
    @required this.child,
  }) : super(key: key);

  factory _PageState.use({
    Key key,
    @required DownloadChaptersPage parent,
    @required Widget child,
  }) {
    assert(child != null);

    final chapter = useChapter(parent.chapterUrl);
    final referenceChapter = useResource<Chapter>();
    final numToDownload = useState<int>(null);
    final isWaitingOnUserInput = numToDownload.value == null;
    final chapters = useChapters(parent.novelSource, isWaitingOnUserInput ? null : parent.novelSlug);

    useEffect(() {
      referenceChapter.value = chapter;
      return () {};
    }, [chapter]);

    return _PageState._(
      key: key,
      anchorChapter: referenceChapter,
      numToDownload: numToDownload,
      chapters: chapters,
      child: child,
    );
  }

  final Widget child;

  final ValueNotifier<Resource<Chapter>> anchorChapter;

  final ValueNotifier<int> numToDownload;

  final PaginatedResource<Chapter> chapters;

  // ignore: use_setters_to_change_properties
  void requestDownload(int numToDownload) {
    this.numToDownload.value = numToDownload;
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

    return ResourceBuilder(
      resource: state.anchorChapter.value,
      doneBuilder: (BuildContext context, Chapter anchorChapter) {
        if (anchorChapter == null) {
          return const Center(
            child: Text("Unable to grab anchor chapter"),
          );
        }

        final waitingForUserInput = state.numToDownload.value == null;
        return AnimatedCrossFade(
          crossFadeState: waitingForUserInput ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: _DownloadActions(),
          secondChild: waitingForUserInput ? const SizedBox.shrink() : _ProcessDownload(),
          duration: const Duration(milliseconds: 400),
        );
      },
    );
  }
}

class _DownloadActions extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final state = _usePageState();
    final anchor = state.anchorChapter.value.data;
    final source = getSource(id: anchor.novelSource);
    final theme = useTheme();
    final platformSupported = defaultTargetPlatform == TargetPlatform.android;

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
        if (platformSupported)
          for (final count in const [10, 50, 100, 250, 500, 1000])
            ListTile(
              contentPadding: const EdgeInsets.only(
                left: 24.0,
                right: 8.0,
              ),
              onTap: () => state.requestDownload(count),
              title: Text("Download next $count chapters"),
            )
        else
          const ListTile(
            contentPadding: EdgeInsets.only(
              left: 24.0,
              right: 8.0,
            ),
            title: Text("Your platform is not supported"),
            enabled: false,
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

class _ProcessDownload extends HookWidget {
  void _download(DownloadsManager manager, List<Chapter> chapters, Chapter anchor, int numToDownload) {
    final anchorIndex = chapters.searchFor(anchor);
    if (anchorIndex >= 0) {
      final urls = <String>[]..length = numToDownload;
      for (var nth = 0; nth < numToDownload; nth++) {
        final i = anchorIndex + nth + 1;
        if (i >= chapters.length) {
          urls.length = nth + 1;
          break;
        }
        urls[nth] = chapters[i].url.toString();
      }

      manager.downloadUrls(urls);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageState = _usePageState();
    final downloadsManager = useDownloadsManager();
    final chapters = pageState.chapters;
    final anchorChapter = pageState.anchorChapter.value;
    final numToDownload = pageState.numToDownload.value;
    final router = useRouter();

    useEffect(() {
      if (chapters.state != ResourceState.done) {
        return () {};
      }
      _download(downloadsManager, chapters.data, anchorChapter.data, numToDownload);
      // Close the page after delay
      const delay = Duration(seconds: 1);
      final timer = Timer(delay, router.pop);
      return timer.cancel;
    }, [chapters.state]);

    return ResourceBuilder(
      resource: chapters,
      doneBuilder: _doneBuilder,
    );
  }

  static Widget _doneBuilder(BuildContext context, List<Chapter> chapters) {
    if (chapters == null) {
      return const Center(
        child: Text("Unable to grab chapter data"),
      );
    }

    return const Center(
      child: Text("Downloading"),
    );
  }
}

extension _ChapterSearch on List<Chapter> {
  int searchFor(Chapter chapter) {
    final candidate = _indexOfSearch(chapter);
    return candidate >= 0 ? candidate : _numberSearch(chapter);
  }

  int _indexOfSearch(Chapter chapter) {
    return indexWhere((element) => element.slug == chapter.slug);
  }

  int _numberSearch(Chapter chapter) {
    final numberMatches = RegExp(r"\d+").allMatches(chapter.title);

    if (numberMatches.isEmpty) {
      return 0;
    }

    final numberRegex = RegExp(r"^((.*[^\d])|)" + numberMatches.map((e) => e[0]).join(r"[^\d]+") + r"(([^\d].*)|)$");
    var candidate = -1;
    for (var i = 0; i < length; i++) {
      if (numberRegex.matchAsPrefix(this[i].title) != null) {
        if (candidate >= 0) {
          return null;
        }
        candidate = i;
      }
    }
    return candidate;
  }
}
