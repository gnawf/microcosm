import "package:flutter/foundation.dart";
import "package:uuid/uuid.dart";

final uuid = Uuid();

extension KeyExtension on Uuid {
  Key key() {
    final value = uuid.v4();
    return Key(value);
  }
}
