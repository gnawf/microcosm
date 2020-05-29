import "package:app/settings/landing_page.dart";
import "package:app/settings/setting.dart";
import "package:flutter/material.dart";
import "package:meta/meta.dart";

class Settings extends StatefulWidget {
  const Settings({@required this.child});

  final Widget child;

  static SettingsState of(BuildContext context) {
    return context.findAncestorStateOfType<SettingsState>();
  }

  @override
  State createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  final _brightness = Setting<int, Brightness>(
    key: "brightness",
    defaultValue: Brightness.light,
    serializer: (brightness) => brightness.index,
    deserializer: (index) => index == null ? null : Brightness.values[index],
  );

  final _amoled = Setting<bool, bool>(
    key: "amoled",
    defaultValue: true,
  );

  final _primarySwatch = Setting<int, MaterialColor>(
    key: "primarySwatch",
    defaultValue: Colors.indigo,
    serializer: (color) => _primaryColors.indexOf(color),
    deserializer: (index) => index == null ? null : _primaryColors[index],
  );

  final _accentColor = Setting<int, MaterialAccentColor>(
    key: "accentColor",
    defaultValue: Colors.indigoAccent,
    serializer: (color) => _accentColors.indexOf(color),
    deserializer: (index) => index == null ? null : _accentColors[index],
  );

  final _readerFontSize = Setting<double, double>(
    key: "readerFontSize",
    defaultValue: 15.0,
  );

  final _landingPage = Setting<int, LandingPage>(
    key: "landingPage",
    defaultValue: LandingPage.browse,
    serializer: _landingPageSerializer,
    deserializer: _landingPageDeserializer,
  );

  final _readerAlignment = Setting<int, WrapAlignment>(
    key: "readerAlignment",
    defaultValue: WrapAlignment.spaceBetween,
    serializer: _readerAlignmentSerializer,
    deserializer: _readerAlignmentDeserializer,
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

  ChangeNotifier get readerFontSizeChanges => _readerFontSize;

  double get readerFontSize => _readerFontSize.value;

  double get defaultReaderFontSize => _readerFontSize.defaultValue;

  set readerFontSize(double value) => _readerFontSize.value = value;

  ChangeNotifier get landingPageChanges => _landingPage;

  LandingPage get landingPage => _landingPage.value;

  LandingPage get defaultLandingPage => _landingPage.defaultValue;

  set landingPage(LandingPage value) => _landingPage.value = value;

  ChangeNotifier get readerAlignmentChanges => _readerAlignment;

  WrapAlignment get readerAlignment => _readerAlignment.value;

  WrapAlignment get defaultReaderAlignment => _readerAlignment.defaultValue;

  set readerAlignment(WrapAlignment value) => _readerAlignment.value = value;

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

const _landingPageToInt = {
  LandingPage.browse: 0,
  LandingPage.open: 1,
  LandingPage.recents: 2,
  LandingPage.downloads: 3,
};

final _intToLandingPage = _landingPageToInt.map((k, v) => MapEntry(v, k));

int _landingPageSerializer(LandingPage page) => _landingPageToInt[page];

LandingPage _landingPageDeserializer(int int) => _intToLandingPage[int];

const _readerAlignmentToInt = {
  WrapAlignment.start: 0,
  WrapAlignment.end: 1,
  WrapAlignment.center: 2,
  WrapAlignment.spaceBetween: 3,
  WrapAlignment.spaceAround: 4,
  WrapAlignment.spaceEvenly: 5,
};

final _intToReaderAlignment = _readerAlignmentToInt.map((k, v) => MapEntry(v, k));

int _readerAlignmentSerializer(WrapAlignment page) => _readerAlignmentToInt[page];

WrapAlignment _readerAlignmentDeserializer(int int) => _intToReaderAlignment[int];
