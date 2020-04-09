import "package:app/models/novel.dart";
import "package:app/resource/paginated_resource.dart";
import "package:app/utils/uuid.dart";
import "package:app/widgets/image_view.dart";
import "package:app/widgets/novel_sliver_grid.dart" show OnTapNovel;
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

class NovelSliverList extends HookWidget {
  const NovelSliverList({
    Key key,
    @required this.novels,
    @required this.onTap,
  })  : assert(novels != null),
        super(key: key);

  final PaginatedResource<Novel> novels;

  final OnTapNovel onTap;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
      ),
      sliver: SliverList(
        delegate: _useListDelegate(novels, onTap),
      ),
    );
  }
}

SliverChildDelegate _useListDelegate(PaginatedResource<Novel> novels, OnTapNovel onTap) {
  final delegate = useState<SliverChildBuilderDelegate>();
  final loaderKey = (useState<Key>()..value ??= uuid.key()).value;

  useEffect(() {
    final data = novels.data;
    final novelCount = data?.length ?? 0;
    final loaderCount = novels.hasMore ? 1 : 0;

    delegate.value = SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return index >= data.length
            ? _Loader(key: loaderKey, novels: novels)
            : _NovelListTile(novel: data[index], onTap: onTap);
      },
      childCount: novelCount + loaderCount,
    );

    return () {};
  }, [novels.data]);

  return delegate.value;
}

class _Loader extends HookWidget {
  _Loader({
    Key key,
    @required this.novels,
  }) : super(key: key);

  final PaginatedResource<Novel> novels;

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(false);

    if (!isLoading.value) {
      () async {
        isLoading.value = true;
        await novels.fetchMore();
        isLoading.value = false;
      }();
    }

    return const Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 24.0,
        ),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _NovelListTile extends HookWidget {
  _NovelListTile({
    Key key,
    this.novel,
    this.onTap,
  }) : assert(novel != null);

  final Novel novel;

  final OnTapNovel onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      onTap: () {
        onTap(novel);
      },
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
      title: Text(novel.name),
    );
  }
}
