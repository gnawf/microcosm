import "dart:math" as math;

import "package:app/hooks/use_novel.hook.dart";
import "package:app/models/chapter.dart";
import "package:app/providers/provider.hooks.dart";
import "package:app/resource/resource.dart";
import "package:app/resource/resource.hooks.dart";
import "package:app/sources/sources.dart";
import "package:app/ui/router.hooks.dart";
import "package:app/widgets/image_view.dart";
import "package:app/widgets/settings_icon_button.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

part "recents_page.hooks.dart";

class RecentsPage extends StatelessWidget {
  const RecentsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        title: const Text("Recently Read"),
        centerTitle: false,
        actions: const [
          SettingsIconButton(),
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
            ),
            sliver: _RecentsList(),
          ),
        ],
      ),
    );
  }
}

class _RecentsList extends HookWidget {
  SliverChildDelegate _placeholderDelegate() {
    return const SliverChildListDelegate.fixed([]);
  }

  SliverChildDelegate _loadingDelegate() {
    return const SliverChildListDelegate.fixed([
      Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      ),
    ]);
  }

  SliverChildDelegate _recentsDelegate(List<Chapter> data) {
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return new _RecentsListEntry(data[index]);
      },
      childCount: math.max(1, data.length),
    );
  }

  SliverChildDelegate _errorDelegate(Object error) {
    return SliverChildListDelegate([
      Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("$error"),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final recents = _useRecents();
    SliverChildDelegate delegate;

    switch (recents.state) {
      case ResourceState.placeholder:
        delegate = _placeholderDelegate();
        break;
      case ResourceState.loading:
        delegate = _loadingDelegate();
        break;
      case ResourceState.done:
        delegate = _recentsDelegate(recents.data);
        break;
      case ResourceState.error:
        delegate = _errorDelegate(recents.error);
        break;
    }

    return SliverList(
      delegate: delegate,
    );
  }
}

class _RecentsListEntry extends HookWidget {
  const _RecentsListEntry(this.chapter);

  final Chapter chapter;

  @override
  Widget build(BuildContext context) {
    final chapterResource = _useChapter(this.chapter);
    final source = useSource(chapterResource.data?.novelSource);

    switch (chapterResource.state) {
      case ResourceState.placeholder:
        return const SizedBox.shrink();
      case ResourceState.loading:
        return const ListTile(
          leading: CircularProgressIndicator(),
          title: Text("Loading"),
        );
      case ResourceState.done:
        break;
      case ResourceState.error:
        return ListTile(
          title: const Text("An Error Ocurred"),
          subtitle: Text("${chapterResource.error}"),
        );
    }

    final chapter = chapterResource.data;
    final novel = chapter.novel;
    final novelName = novel?.name ?? chapter.novelSlug ?? "Unknown";
    final sourceName = source.name ?? chapter.novelSource ?? "Unknown";
    final title = "$novelName from $sourceName";

    return ListTile(
      onTap: _useOpenRecent(chapter),
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
      subtitle: Text(title),
    );
  }
}
