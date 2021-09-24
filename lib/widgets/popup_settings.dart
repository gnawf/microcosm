import "package:app/dialogs/color_picker_dialog.dart";
import "package:app/dialogs/font_size_picker_dialog.dart";
import "package:app/hooks/use_animation.hook.dart";
import "package:app/hooks/use_list_state.hook.dart";
import "package:app/hooks/use_settings.hook.dart";
import "package:app/settings/landing_page.dart";
import "package:app/settings/settings.dart";
import "package:app/ui/router.hooks.dart";
import "package:app/widgets/md_icons.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

part "popup_settings.widgets.dart";

class PopupSettings extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: _Popup(),
      ),
    );
  }
}

class _Popup extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final settings = _useSettings();

    final router = useRouter();

    final controller = useAnimationController(
      duration: const Duration(milliseconds: 400),
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth.clamp(0.0, 512.0);
    final cardHeight = 88.0 + 56.0 * settings.length;

    const widthCurve = Interval(0.0, 0.85, curve: Curves.easeOutCubic);
    final widthTween = useState<Tween>(null)..value ??= Tween(begin: 0.0, end: 1.0);
    final widthAnim = useAnim(controller, widthTween.value, curve: widthCurve);

    const heightCurve = Interval(0.25, 1.0, curve: Curves.easeInCubic);
    final heightTween = useState<Tween>(null)..value ??= Tween(begin: 48.0 / cardHeight, end: 1.0);
    final heightAnim = useAnim(controller, heightTween.value, curve: heightCurve);

    const opacityCurve = Interval(0.1, 1.0, curve: Curves.easeInQuint);
    final opacityTween = useState<Tween>(null)..value ??= Tween(begin: 0.0, end: 1.0);
    final opacityAnim = useAnim(controller, opacityTween.value, curve: opacityCurve);

    useEffect(() {
      controller.forward();
      return controller.stop;
    }, []);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        await controller.animateTo(0.0);
        router.pop();
      },
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AnimatedBuilder(
            animation: controller,
            builder: (BuildContext context, Widget child) {
              return Transform(
                transform: Matrix4.diagonal3Values(
                  widthAnim.value,
                  heightAnim.value,
                  1.0,
                ),
                alignment: Alignment.topRight,
                child: Container(
                  width: cardWidth,
                  height: cardHeight,
                  child: Card(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      // This ensures the taps don't go through the card
                      onTap: () {},
                      child: Opacity(
                        opacity: opacityAnim.value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                            horizontal: 8.0,
                          ),
                          child: Column(
                            children: <Widget>[
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                  ),
                                  child: Text(
                                    "Settings",
                                    style: Theme.of(context).textTheme.headline6,
                                  ),
                                ),
                              ),
                              ...settings,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

List<Widget> _useSettings() {
  final settings = useListState<Widget>();

  useEffect(() {
    settings.value = [
      _DarkThemeSetting(),
      _AmoledSetting(),
      _PrimaryColorSetting(),
      _AccentColorSetting(),
      _ReaderFontSizeSetting(),
      _LandingPageSetting(),
      _ReaderAlignmentSetting(),
    ];
    return () {};
  });

  final changes = useSettings();
  useListenable(changes.brightnessChanges);
  useListenable(changes.amoledChanges);
  useListenable(changes.primarySwatchChanges);
  useListenable(changes.accentColorChanges);
  useListenable(changes.readerFontSizeChanges);
  useListenable(changes.landingPageChanges);
  useListenable(changes.readerAlignmentChanges);

  return settings.value;
}
