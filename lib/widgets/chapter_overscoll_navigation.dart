import "package:app/hooks/use_animation.hook.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

typedef OverscrollNavigate = void Function(AxisDirection direction);

enum _Mode {
  idle,
  drag,
  armed,
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
    final overscroll = useState(0.0);

    final anim = useAnimationController(
      duration: const Duration(milliseconds: 400),
    );
    final offsetAnim = useAnim(anim, _offsetTween);
    final opacityAnim = useAnim(anim, _opacityTween, curve: Curves.easeInQuad);

    final cancel = () {
      mode.value = _Mode.idle;
      anim.animateTo(0.0);
    };

    final scroll = (double delta) {
      overscroll.value += delta;
      anim.value = overscroll.value / threshold;
      mode.value = overscroll.value >= threshold ? _Mode.armed : _Mode.drag;
      if (delta < 0) {
        cancel();
      }
    };

    final onScrollNotification = (ScrollNotification notification) {
      if (onNavigate == null) {
        return false;
      }

      final metrics = notification.metrics;

      if (notification is ScrollStartNotification) {
        mode.value = metrics.extentAfter == 0 ? _Mode.drag : _Mode.idle;
        direction.value = AxisDirection.down;
        overscroll.value = 0.0;
      } else if (notification is ScrollEndNotification) {
        if (mode.value == _Mode.armed) {
          onNavigate(AxisDirection.down);
        }
        cancel();
      } else if (notification is ScrollUpdateNotification) {
        if (mode.value != _Mode.idle) {
          scroll(notification.scrollDelta);
        }
      } else if (notification is OverscrollNotification) {
        if (mode.value != _Mode.idle) {
          scroll(notification.overscroll / 2.0);
        }
      }

      return false;
    };

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          key: _key,
          onNotification: onScrollNotification,
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: _handleGlowNotification,
            child: child,
          ),
        ),
        AnimatedBuilder(
          animation: offsetAnim,
          builder: (BuildContext context, Widget widget) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: Transform.translate(
                offset: offsetAnim.value,
                child: Opacity(
                  opacity: opacityAnim.value,
                  child: const Chip(
                    label: Text("Next Chapter"),
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
