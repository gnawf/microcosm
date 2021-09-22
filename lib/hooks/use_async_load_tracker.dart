import "package:app/utils/async_load_tracker.dart";
import "package:flutter_hooks/flutter_hooks.dart";

AsyncLoadTracker useAsyncLoadTracker() {
  return (useState<AsyncLoadTracker>(null)..value ??= AsyncLoadTracker()).value;
}
