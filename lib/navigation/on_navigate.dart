import "package:flutter/widgets.dart";

typedef OnStopUserGesture = void Function();
typedef OnStartUserGesture = void Function(Route<dynamic> route, Route<dynamic> previousRoute);
typedef OnReplace = void Function({Route<dynamic> newRoute, Route<dynamic> oldRoute});
typedef OnRemove = void Function(Route<dynamic> route, Route<dynamic> previousRoute);
typedef OnPop = void Function(Route<dynamic> route, Route<dynamic> previousRoute);
typedef OnPush = void Function(Route<dynamic> route, Route<dynamic> previousRoute);

class OnNavigate extends NavigatorObserver {
  OnNavigate({
    this.onStopUserGesture,
    this.onStartUserGesture,
    this.onReplace,
    this.onRemove,
    this.onPop,
    this.onPush,
  });

  final OnStopUserGesture onStopUserGesture;
  final OnStartUserGesture onStartUserGesture;
  final OnReplace onReplace;
  final OnRemove onRemove;
  final OnPop onPop;
  final OnPush onPush;

  @override
  void didStopUserGesture() {
    final cb = onStopUserGesture;
    if (cb != null) {
      cb();
    }
  }

  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic> previousRoute) {
    final cb = onStartUserGesture;
    if (cb != null) {
      cb(route, previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    final cb = onReplace;
    if (cb != null) {
      cb(newRoute: newRoute, oldRoute: oldRoute);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    final cb = onRemove;
    if (cb != null) {
      cb(route, previousRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    final cb = onPop;
    if (cb != null) {
      cb(route, previousRoute);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    final cb = onPush;
    if (cb != null) {
      cb(route, previousRoute);
    }
  }
}
