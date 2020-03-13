import "package:app/resource/resource.dart";
import "package:meta/meta.dart";

class PaginatedResource<T> extends Resource<List<T>> {
  const PaginatedResource.data(
    List<T> data, {
    @required this.cursor,
    this.limit,
  })  : assert(cursor != null),
        super.data(data);

  const PaginatedResource.error(
    Object error, {
    this.cursor,
    this.limit,
  })  : assert(cursor != null),
        super.error(error);

  const PaginatedResource.loading({
    this.cursor,
    this.limit,
  }) : super.loading();

  const PaginatedResource.placeholder({
    this.cursor,
    this.limit,
  }) : super.placeholder();

  final Object cursor;
  final int limit;
}
