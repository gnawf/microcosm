import "dart:async";

import "package:app/hooks/use_debounced_value.dart";
import "package:app/hooks/use_list_state.hook.dart";
import "package:app/models/novel.dart";
import "package:app/sources/source.dart";
import "package:app/sources/sources.dart";
import "package:app/ui/router.hooks.dart";
import "package:app/widgets/image_view.dart";
import "package:app/widgets/settings_icon_button.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:flutter_hooks/flutter_hooks.dart";

part "search_page.hooks.dart";

class SearchPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return _PageState.useState(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Search"),
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
  _PageState({
    @required this.source,
    @required this.isLoading,
    @required this.searchFieldController,
    @required this.child,
  }) : assert(child != null);

  factory _PageState.useState({@required Widget child}) {
    final sources = useSources();
    final source = useState(sources[0]);
    final isLoading = useState(false);
    final searchFieldController = useTextEditingController();

    return _PageState(
      source: source,
      isLoading: isLoading,
      searchFieldController: searchFieldController,
      child: child,
    );
  }

  final ValueNotifier<Source> source;

  final ValueNotifier<bool> isLoading;

  final TextEditingController searchFieldController;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class _Body extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final sources = useSources();
    final pageState = _usePageState();
    final source = pageState.source;
    final isLoading = pageState.isLoading;
    final searchFieldController = pageState.searchFieldController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            top: 16.0,
            right: 16.0,
            bottom: 8.0,
          ),
          child: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Search Query",
            ),
            controller: searchFieldController,
          ),
        ),
        Material(
          elevation: 1.0,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 24.0,
              right: 16.0,
              bottom: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if (isLoading.value)
                  Transform.scale(
                    scale: 0.65,
                    child: const CircularProgressIndicator(),
                  ),
                const SizedBox.shrink(),
                DropdownButton(
                  value: source.value,
                  onChanged: (selected) {
                    source.value = selected;
                  },
                  items: [
                    for (final source in sources)
                      DropdownMenuItem(
                        value: source,
                        child: Text(source.name),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _SearchResults(),
        ),
      ],
    );
  }
}

class _SearchResults extends HookWidget {
  _SearchResults({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageState = _usePageState();
    final searchFieldController = pageState.searchFieldController;
    final source = pageState.source.value;
    final isLoading = pageState.isLoading;
    final results = useListState<Novel>(const []);

    // Auto update view when search value changes
    useListenable(searchFieldController);

    Future<void> search(String text) async {
      await null;

      isLoading.value = true;
      try {
        final result = await source.novels.search(query: text);
        results.value = result.data ?? [];
      } finally {
        isLoading.value = false;
      }
    }

    // Invokes search after the search field is stable or timeout
    useDebouncedValue(value: searchFieldController.text, onTimeout: search);

    useValueChanged(source, (oldValue, oldResult) {
      results.value = [];
      search(searchFieldController.text);
    });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        vertical: 16.0,
      ),
      itemBuilder: (BuildContext context, int index) {
        return _SearchResult(novel: results.value[index]);
      },
      itemCount: results.value.length,
    );
  }
}

class _SearchResult extends HookWidget {
  _SearchResult({
    Key key,
    this.novel,
  })  : assert(novel != null),
        super(key: key);

  final Novel novel;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: _useOpenNovel(novel),
      contentPadding: const EdgeInsets.only(
        left: 24.0,
        top: 8.0,
        right: 4.0,
        bottom: 8.0,
      ),
      leading: SizedBox(
        width: 40.0,
        height: 60.0,
        child: Hero(
          tag: novel.slug,
          child: ImageView(
            image: novel.posterImage,
          ),
        ),
      ),
      title: Text(novel.name),
    );
  }
}
