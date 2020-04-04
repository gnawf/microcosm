import "package:flutter/cupertino.dart";
import "package:flutter_hooks/flutter_hooks.dart";

ValueNotifier<List<T>> useListState<T>([List<T> initialData]) {
  return useState(initialData);
}
