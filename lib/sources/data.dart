import "package:meta/meta.dart";

class Data<T> {
  Data({
    @required this.data,
    this.extras,
  });

  final T data;
  final Map<String, dynamic> extras;
}

class DataList<T> extends Data<List<T>> {
  DataList({
    List<T> data,
    Map<String, dynamic> extras,
  }) : super(data: data, extras: extras);
}
