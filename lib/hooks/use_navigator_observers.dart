import "package:flutter/widgets.dart";
import "package:flutter_hooks/flutter_hooks.dart";

void useNavigatorObserver(NavigatorObserver observer) {
  final context = useContext();
  final observers = Navigator.of(context).widget.observers;

  useEffect(() {
    observers.add(observer);
    return () {
      observers.remove(observer);
    };
  });
}
