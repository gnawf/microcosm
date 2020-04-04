import "dart:async";

import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";

typedef Stored Serializer<Stored, Concrete>(Concrete value);

typedef Concrete Deserializer<Stored, Concrete>(Stored value);

class Setting<Stored, Concrete> extends ChangeNotifier {
  Setting({
    this.key,
    this.defaultValue,
    this.serializer,
    this.deserializer,
  }) : assert(// Require a de(serializer) when stored type != concrete type
            Stored == Concrete || serializer != null && deserializer != null) {
    _init();
  }

  final String key;

  final Concrete defaultValue;

  final Serializer<Stored, Concrete> serializer;

  final Deserializer<Stored, Concrete> deserializer;

  Concrete _value;

  Concrete get value => _value;

  set value(Concrete value) {
    if (value != _value) {
      _value = value;
      _save(value);
      notifyListeners();
    }
  }

  Future<void> _init() async {
    final store = await SharedPreferences.getInstance();
    Stored stored;
    if (Stored == int) {
      stored = store.getInt(key) as Stored; // ignore: avoid_as
    } else if (Stored == bool) {
      stored = store.getBool(key) as Stored; // ignore: avoid_as
    } else if (Stored == double) {
      stored = store.getDouble(key) as Stored; // ignore: avoid_as
    } else if (Stored == String) {
      stored = store.getString(key) as Stored; // ignore: avoid_as
    }
    final value = deserializer == null ? stored : deserializer(stored);
    _value = value ?? defaultValue;
    notifyListeners();
  }

  Future<void> _save(Concrete value) async {
    final store = await SharedPreferences.getInstance();
    final stored = serializer == null ? value : serializer(value);
    if (Stored == int) {
      store.setInt(key, stored);
    } else if (Stored == bool) {
      store.setBool(key, stored);
    } else if (Stored == double) {
      store.setDouble(key, stored);
    } else if (Stored == String) {
      store.setString(key, stored);
    }
  }
}
