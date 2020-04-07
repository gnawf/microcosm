import "package:flutter/material.dart";
import "package:provider/provider.dart";

class AsyncProvider<T> extends StatefulWidget {
  const AsyncProvider({
    Key key,
    this.create,
    this.child,
  }) : super(key: key);

  final Create<Future<T>> create;
  final Widget child;

  @override
  State createState() => _AsyncProviderState<T>();
}

class _AsyncProviderState<T> extends State<AsyncProvider<T>> {
  var _creating = false;
  var _ready = false;
  T _value;

  @override
  Widget build(BuildContext context) {
    if (!_creating) {
      _creating = true;
      // Create the dependency
      widget.create(context).then((value) {
        setState(() {
          _value = value;
          _ready = true;
        });
      });
    }

    if (!_ready) {
      return const SizedBox.shrink();
    }

    return Provider<T>(
      create: (BuildContext context) {
        return _value;
      },
      child: widget.child,
    );
  }
}
