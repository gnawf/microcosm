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
    Key key,
    @required this.child,
    this.threshold = 60,
    this.onNavigate,
  })  : assert(threshold != null),
        _offsetTween = Tween<Offset>(
          begin: Offset(0, threshold),
          end: const Offset(0, -8.0),
        ),
        super(key: key);

  final Widget child;

  final OverscrollNavigate onNavigate;

  final double threshold;

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
    final direction = useState<AxisDirection>(null);
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
        mode.value = metrics.extentAfter <= 10 ? _Mode.drag : _Mode.idle;
        direction.value = AxisDirection.down;
        overscroll.value = 0.0;
      } else if (notification is ScrollEndNotification) {
        // This is for Android: fire once scroll ends i.e. user lets go
        if (mode.value == _Mode.armed) {
          onNavigate(AxisDirection.down);
          mode.value = _Mode.idle;
        }
        cancel();
      } else if (notification is ScrollUpdateNotification) {
        // iOS: fire as soon as the user lets go i.e. dragDetails=null
        if (mode.value == _Mode.armed && notification.dragDetails == null) {
          onNavigate(AxisDirection.down);
          mode.value = _Mode.idle;
        } else if (mode.value != _Mode.idle) {
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
