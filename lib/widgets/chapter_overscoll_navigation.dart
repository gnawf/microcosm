import "package:app/hooks/use_animation.hook.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

typedef OverscrollNavigate = void Function(AxisDirection direction);

enum _Mode {
  idle,
  drag,
}

class ChapterOverscrollNavigation extends HookWidget {
  ChapterOverscrollNavigation({
    @required this.child,
    this.threshold = 60,
    this.onNavigate,
  })  : assert(threshold != null),
        _offsetTween = Tween<Offset>(
          begin: Offset(0, threshold),
          end: const Offset(0, -8.0),
        );

  final Widget child;

  final OverscrollNavigate onNavigate;

  final double threshold;

  final GlobalKey _key = GlobalKey();

  final Tween<Offset> _offsetTween;

  final Tween<double> _opacityTween = Tween<double>(
    begin: 0.2,
    end: 1.0,
  );

  bool _handleGlowNotification(OverscrollIndicatorNotification notification) {
    if (onNavigate != null) {
      notification.disallowGlow();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final direction = useState<AxisDirection>();
    final mode = useState(_Mode.idle);

    final anim = useAnimationController();
    final offsetAnim = useAnim(anim, _offsetTween);
    final opacityAnim = useAnim(anim, _opacityTween, curve: Curves.easeInQuad);

    final onScroll = (ScrollNotification notification) {
      final metrics = notification.metrics;

      if (notification is ScrollStartNotification) {
        mode.value = metrics.extentAfter == 0 ? _Mode.drag : _Mode.idle;
        direction.value = AxisDirection.down;
      } else if (notification is ScrollEndNotification) {
        mode.value = _Mode.idle;
      } else if (notification is ScrollUpdateNotification) {
        if (mode.value == _Mode.drag) {
          final overscroll = metrics.pixels - metrics.maxScrollExtent;
          anim.value = overscroll / threshold;
          if (onNavigate != null) {
            if (notification.dragDetails == null && overscroll >= threshold) {
              onNavigate(direction.value);
            }
          }
        }
      }

      return false;
    };

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          key: _key,
          onNotification: onScroll,
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: _handleGlowNotification,
            child: child,
          ),
        ),
        AnimatedBuilder(
          animation: offsetAnim,
          builder: (BuildContext context, Widget widget) {
            return Container(
              alignment: Alignment.bottomCenter,
              child: Positioned(
                bottom: 0.0,
                child: Transform.translate(
                  offset: offsetAnim.value,
                  child: Opacity(
                    opacity: opacityAnim.value,
                    child: const Chip(
                      label: Text("Next Chapter"),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
