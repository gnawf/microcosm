import "package:flutter/foundation.dart";
import "package:flutter_hooks/flutter_hooks.dart";

ValueListenable<bool> useIsDisposed() {
  // Yes [useState] returns a ValueNotifier too, but we can't use that – as soon as
  // the useEffect [Dispose] callback is invoked, we can no longer write to it. But
  // we can still read from it, thus why we use it to store our own ValueNotifier.
  final state = useState<ValueNotifier<bool>>(null)..value ??= ValueNotifier(false);

  useEffect(() {
    return () {
      state.value.value = true;
      state.value.dispose();
    };
  }, []);

  return state.value;
}
