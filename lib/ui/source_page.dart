import "package:app/hooks/use_novels.hook.dart";
import "package:app/resource/resource.dart";
import "package:app/sources/source.dart";
import "package:app/sources/sources.dart";
import "package:app/ui/router.hooks.dart";
import "package:app/widgets/md_icons.dart";
import "package:app/widgets/novel_sliver_grid.dart";
import "package:app/widgets/novel_sliver_list.dart";
import "package:app/widgets/settings_icon_button.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

part "source_page.hooks.dart";

class SourcePage extends HookWidget {
  const SourcePage({
    Key key,
    @required this.sourceId,
  }) : super(key: key);

  final String sourceId;

  @override
  Widget build(BuildContext context) {
    return _PageState.use(
      sourceId: sourceId,
      child: Scaffold(
        appBar: _AppBar(),
        body: _Novels(),
      ),
    );
  }
}

class _PageState extends StatelessWidget {
  const _PageState._({
    Key key,
    @required this.isGridView,
    @required this.source,
    @required this.child,
  })  : assert(source != null),
        assert(child != null),
        super(key: key);

  factory _PageState.use({
    Key key,
    @required String sourceId,
    @required Widget child,
  }) {
    final isGridView = useState(true);
    final source = useSource(id: sourceId);

    return _PageState._(
      key: key,
      isGridView: isGridView,
      source: source,
      child: child,
    );
  }

  final ValueNotifier<bool> isGridView;

  final Source source;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _AppBarTitle(),
      centerTitle: false,
      actions: [
        _ChangeViewType(),
        const SettingsIconButton(),
      ],
    );
  }
}

class _AppBarTitle extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final state = _usePageState();
    final source = state.source;
    return Text(source.name);
  }
}

class _ChangeViewType extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final pageState = _usePageState();

    return IconButton(
      onPressed: () {
        pageState.isGridView.value = !pageState.isGridView.value;
      },
      icon: Icon(pageState.isGridView.value ? MDIcons.viewList : MDIcons.viewGrid),
    );
  }
}

class _Novels extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final state = _usePageState();
    final source = state.source;
    final novels = useNovels(source);
    final onTapNovel = _useOnTapNovel();

    switch (novels.state) {
      case ResourceState.placeholder:
        return const SizedBox.shrink();
      case ResourceState.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case ResourceState.done:
        break;
      case ResourceState.error:
        return Center(
          child: Text("${novels.error}"),
        );
    }

    return CustomScrollView(
      slivers: <Widget>[
        state.isGridView.value
            ? NovelSliverGrid(
                novels: novels,
                onTap: onTapNovel,
              )
            : NovelSliverList(
                novels: novels,
                onTap: onTapNovel,
              ),
      ],
    );
  }
}
