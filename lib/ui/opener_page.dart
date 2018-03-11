import "dart:async";

import "package:app/ui/routes.dart" as routes;
import "package:app/widgets/settings_icon_button.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

class OpenerPage extends StatefulWidget {
  const OpenerPage();

  @override
  State createState() => new _OpenerPageState();
}

class _OpenerPageState extends State<OpenerPage> {
  final TextEditingController _url = new TextEditingController();

  Future<Null> _paste() async {
    final paste = await Clipboard.getData("text/plain");
    _url.text = paste.text;
  }

  void _open() {
    if (_url.text.isNotEmpty) {
      try {
        final url = Uri.parse(_url.text);
        Navigator.of(context).push(routes.reader(url: url));
      } on FormatException catch (e) {
        print(e);
      }
    }
  }

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        title: const Text("Microcosm"),
        centerTitle: false,
        actions: const <Widget>[
          const SettingsIconButton(),
        ],
      ),
      body: new Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
        ),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new TextField(
              controller: _url,
              autofocus: true,
              autocorrect: false,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                hintText: "Enter your chapter link",
                border: const OutlineInputBorder(),
              ),
            ),
            new Padding(
              padding: const EdgeInsets.only(
                top: 32.0,
                left: 2.0,
                right: 2.0,
              ),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new RaisedButton(
                    onPressed: _url.clear,
                    child: const Text("Clear"),
                  ),
                  new RaisedButton(
                    onPressed: _paste,
                    child: const Text("Paste"),
                  ),
                  new RaisedButton(
                    onPressed: _open,
                    child: const Text("Open"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomPadding: false,
    );
  }
}
