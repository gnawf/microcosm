import "package:app/resource/resource.dart";

typedef Future<void> FetchMore();

class PaginatedResource<T> extends Resource<List<T>> {
  const PaginatedResource.data(
    List<T> data, {
    this.hasMore = false,
    this.fetchMore,
  })  : assert(hasMore != null),
        super.data(data);

  const PaginatedResource.error(
    Object error, {
    this.hasMore = false,
    this.fetchMore,
  })  : assert(hasMore != null),
        super.error(error);

  const PaginatedResource.loading({
    this.hasMore = false,
    this.fetchMore,
  })  : assert(hasMore != null),
        super.loading();

  const PaginatedResource.placeholder({
    this.hasMore = false,
    this.fetchMore,
  })  : assert(hasMore != null),
        super.placeholder();

  final bool hasMore;
  final FetchMore fetchMore;
}
