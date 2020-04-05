import "dart:async";

import "package:flutter/material.dart";
import "package:meta/meta.dart";

typedef ResourceRefresher = Future<void> Function();

enum ResourceState {
  placeholder,
  loading,
  done,
  error,
}

@immutable
class Resource<T> {
  const Resource.placeholder({ResourceRefresher onRefresh})
      : state = ResourceState.placeholder,
        data = null,
        error = null,
        _onRefresh = onRefresh;

  const Resource.loading({ResourceRefresher onRefresh})
      : state = ResourceState.loading,
        data = null,
        error = null,
        _onRefresh = onRefresh;

  const Resource.data(this.data, {ResourceRefresher onRefresh})
      : state = ResourceState.done,
        error = null,
        _onRefresh = onRefresh;

  const Resource.error(this.error, {ResourceRefresher onRefresh})
      : state = ResourceState.error,
        data = null,
        _onRefresh = onRefresh;

  final ResourceState state;
  final T data;
  final Object error;
  final ResourceRefresher _onRefresh;

  Future<void> refresh() {
    return _onRefresh();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Resource &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          data == other.data &&
          error == other.error;

  @override
  int get hashCode => state.hashCode ^ data.hashCode ^ error.hashCode;

  @override
  String toString() {
    return "Resource{state: $state, data: $data, error: $error}";
  }
}
