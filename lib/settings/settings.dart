import "package:app/settings/setting.dart";
import "package:flutter/material.dart";
import "package:meta/meta.dart";

class Settings extends StatefulWidget {
  const Settings({@required this.child});

  final Widget child;

  static SettingsState of(BuildContext context) {
    const matcher = const TypeMatcher<SettingsState>();
    return context.ancestorStateOfType(matcher);
  }

  @override
  State createState() => new SettingsState();
}

class SettingsState extends State<Settings> {
  final _brightness = new Setting<int, Brightness>(
    key: "brightness",
    defaultValue: Brightness.light,
    serializer: (brightness) => brightness.index,
    deserializer: (index) => index == null ? null : Brightness.values[index],
  );

  final _amoled = new Setting<bool, bool>(
    key: "amoled",
    defaultValue: true,
  );

  final _primarySwatch = new Setting<int, MaterialColor>(
    key: "primarySwatch",
    defaultValue: Colors.indigo,
    serializer: (color) => _primaryColors.indexOf(color),
    deserializer: (index) => index == null ? null : _primaryColors[index],
  );

  final _accentColor = new Setting<int, MaterialAccentColor>(
    key: "accentColor",
    defaultValue: Colors.indigoAccent,
    serializer: (color) => _accentColors.indexOf(color),
    deserializer: (index) => index == null ? null : _accentColors[index],
  );

  final _lastChapterUrl = new Setting<String, String>(
    key: "lastChapterUrl",
  );

  final _readerFontSize = new Setting<double, double>(
    key: "readerFontSize",
    defaultValue: 15.0,
  );

  ChangeNotifier get brightnessChanges => _brightness;

  Brightness get brightness => _brightness.value;

  set brightness(Brightness value) => _brightness.value = value;

  ChangeNotifier get amoledChanges => _amoled;

  bool get amoled => _amoled.value;

  set amoled(bool value) => _amoled.value = value;

  ChangeNotifier get primarySwatchChanges => _primarySwatch;

  MaterialColor get primarySwatch => _primarySwatch.value;

  set primarySwatch(MaterialColor value) => _primarySwatch.value = value;

  ChangeNotifier get accentColorChanges => _accentColor;

  MaterialAccentColor get accentColor => _accentColor.value;

  set accentColor(MaterialAccentColor value) => _accentColor.value = value;

  ChangeNotifier get lastChapterUrlChanges => _lastChapterUrl;

  String get lastChapterUrl => _lastChapterUrl.value;

  set lastChapterUrl(String value) => _lastChapterUrl.value = value;

  ChangeNotifier get readerFontSizeChanges => _readerFontSize;

  double get readerFontSize => _readerFontSize.value;

  double get defaultReaderFontSize => _readerFontSize.defaultValue;

  set readerFontSize(double value) => _readerFontSize.value = value;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Copied to ensure that the indices remain constant
/// Any new additions must be added to the end for backwards comparability
const _primaryColors = const <MaterialColor>[
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
  Colors.blueGrey,
];

/// Copied to ensure that the indices remain constant
/// Any new additions must be added to the end for backwards comparability
const _accentColors = const <MaterialAccentColor>[
  Colors.redAccent,
  Colors.pinkAccent,
  Colors.purpleAccent,
  Colors.deepPurpleAccent,
  Colors.indigoAccent,
  Colors.blueAccent,
  Colors.lightBlueAccent,
  Colors.cyanAccent,
  Colors.tealAccent,
  Colors.greenAccent,
  Colors.lightGreenAccent,
  Colors.limeAccent,
  Colors.yellowAccent,
  Colors.amberAccent,
  Colors.orangeAccent,
  Colors.deepOrangeAccent,
];
