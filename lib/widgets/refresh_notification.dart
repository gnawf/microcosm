import "package:flutter/material.dart";
import "package:meta/meta.dart";

@immutable
class RefreshNotification extends Notification {
  const RefreshNotification({this.what, this.complete});

  /// Use this to aim this refresh notification at a specific widget type
  final Type what;

  /// The notification receiver should invoke this once the refresh is complete
  final VoidCallback complete;
}
