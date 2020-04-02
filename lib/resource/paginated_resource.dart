import "package:app/resource/resource.dart";

typedef Future<void> FetchMore();

class PaginatedResource<T> extends Resource<List<T>> {
  const PaginatedResource.data(
    List<T> data, {
    this.hasMore,
    this.fetchMore,
  }) : super.data(data);

  const PaginatedResource.error(
    Object error, {
    this.hasMore,
    this.fetchMore,
  }) : super.error(error);

  const PaginatedResource.loading({
    this.hasMore,
    this.fetchMore,
  }) : super.loading();

  const PaginatedResource.placeholder({
    this.hasMore,
    this.fetchMore,
  }) : super.placeholder();

  final bool hasMore;
  final FetchMore fetchMore;
}
