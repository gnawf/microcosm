import "package:flutter/animation.dart";
import "package:flutter_hooks/flutter_hooks.dart";

Animation<T> useAnim<T>(Animation parent, Animatable child, {Curve curve}) {
  final animation = useState<Animation<T>>();
  animation.value ??= child.animate(
    curve != null ? CurvedAnimation(curve: curve, parent: parent) : parent,
  );
  return animation.value;
}
