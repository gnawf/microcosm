import "package:app/resource/paginated_resource.dart";
import "package:app/resource/resource.dart";
import "package:flutter/foundation.dart";
import "package:flutter_hooks/flutter_hooks.dart";

ValueNotifier<Resource<T>> useResource<T>([
  Resource<T> initialData = const Resource.placeholder(),
]) {
  return useState(initialData);
}

ValueNotifier<PaginatedResource<T>> usePaginatedResource<T>([
  PaginatedResource<T> initialData = const PaginatedResource.placeholder(),
]) {
  return useState(initialData);
}
