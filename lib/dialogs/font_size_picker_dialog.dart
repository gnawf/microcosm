import "dart:async";

import "package:flutter/material.dart";

Future<double> showFontSizePickerDialog({
  BuildContext context,
  Widget title,
  double min,
  double max,
  double value,
  double defaultValue,
}) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return new _Dialog(title, min, max, value, defaultValue);
    },
  );
}

class _Dialog extends StatefulWidget {
  const _Dialog(this.title, this.min, this.max, this.value, this.defaultValue);

  final Widget title;

  final double min;

  final double max;

  final double value;

  final double defaultValue;

  @override
  State createState() => new _DialogState();
}

class _DialogState extends State<_Dialog> {
  double _value;

  @override
  void initState() {
    super.initState();

    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title;
    final min = widget.min;
    final max = widget.max;
    final defaultValue = widget.defaultValue;

    return new AlertDialog(
      title: title,
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Slider(
            label: "$_value",
            value: _value,
            min: min,
            max: max,
            divisions: (max - min) ~/ 1 * 2,
            onChanged: (value) => setState(() => _value = value),
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () => Navigator.of(context).pop(defaultValue),
          child: const Text("Reset"),
        ),
        new FlatButton(
          onPressed: () => Navigator.of(context).pop(_value),
          child: const Text("Set"),
        ),
      ],
    );
  }
}
