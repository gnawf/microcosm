import "dart:async";

import "package:flutter/material.dart";
import "package:meta/meta.dart";

Future<MaterialColor> openPrimarySwatchPicker(
  BuildContext context, {
  MaterialColor selected,
}) {
  return openColorPicker<MaterialColor>(
    context,
    title: const Text("Choose Primary Color"),
    selected: selected,
    colors: const <String, MaterialColor>{
      "Red": Colors.red,
      "Pink": Colors.pink,
      "Purple": Colors.purple,
      "Deep Purple": Colors.deepPurple,
      "Indigo": Colors.indigo,
      "Blue": Colors.blue,
      "Light Blue": Colors.lightBlue,
      "Cyan": Colors.cyan,
      "Teal": Colors.teal,
      "Green": Colors.green,
      "Light Green": Colors.lightGreen,
      "Lime": Colors.lime,
      "Yellow": Colors.yellow,
      "Amber": Colors.amber,
      "Orange": Colors.orange,
      "Deep Orange": Colors.deepOrange,
      "Brown": Colors.brown,
      "Blue Grey": Colors.blueGrey,
    },
  );
}

Future<MaterialAccentColor> openAccentColorPicker(
  BuildContext context, {
  MaterialAccentColor selected,
}) {
  return openColorPicker<MaterialAccentColor>(
    context,
    title: const Text("Choose Accent Color"),
    selected: selected,
    colors: const <String, MaterialAccentColor>{
      "Red": Colors.redAccent,
      "Pink": Colors.pinkAccent,
      "Purple": Colors.purpleAccent,
      "Deep Purple": Colors.deepPurpleAccent,
      "Indigo": Colors.indigoAccent,
      "Blue": Colors.blueAccent,
      "Light Blue": Colors.lightBlueAccent,
      "Cyan": Colors.cyanAccent,
      "Teal": Colors.tealAccent,
      "Green": Colors.greenAccent,
      "Light Green": Colors.lightGreenAccent,
      "Lime": Colors.limeAccent,
      "Yellow": Colors.yellowAccent,
      "Amber": Colors.amberAccent,
      "Orange": Colors.orangeAccent,
      "Deep Orange": Colors.deepOrangeAccent,
    },
  );
}

Future<T> openColorPicker<T extends Color>(
  BuildContext context, {
  Text title,
  T selected,
  @required Map<String, T> colors,
}) async {
  return await showDialog(
    context: context,
    child: new AlertDialog(
      title: title ?? const Text("Color Picker"),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      content: new SingleChildScrollView(
        child: new ListBody(
          children: colors.keys.map<Widget>((name) {
            final color = colors[name];
            return new ListTile(
              onTap: () => Navigator.of(context).pop(color),
              title: new Text(
                name,
                style: new TextStyle(
                  fontWeight:
                      color == selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: new Container(width: 30.0, height: 30.0, color: color),
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
      ],
    ),
  );
}
