import "dart:async";

import "package:app/hooks/use_is_disposed.hook.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:meta/meta.dart";

typedef Consumer<T> = dynamic Function(T t);

/// Emits a value after either:
/// Once the value doesn't change for the duration of [idleTimeout]
/// Once the value keeps changing changing for the duration of [maxTimeout]
/// Used for search functionality
void useDebouncedValue({
  @required String value,
  @required Consumer<String> onTimeout,
  Duration maxTimeout = const Duration(milliseconds: 1600),
  Duration idleTimeout = const Duration(milliseconds: 500),
}) {
  assert(value != null);
  assert(onTimeout != null);

  final isDisposed = useIsDisposed();
  final lastSearchAt = useState<DateTime>(null)..value ??= DateTime.now();

  useEffect(() {
    final now = DateTime.now();

    if (now.difference(lastSearchAt.value) > maxTimeout) {
      lastSearchAt.value = now;
      onTimeout(value);
      return () {};
    }

    final timer = Timer(idleTimeout, () {
      if (isDisposed.value) {
        return;
      }
      lastSearchAt.value = now.add(idleTimeout);
      onTimeout(value);
    });

    // Cancel the timer once the search field changes
    return timer.cancel;
  }, [value]);
}
