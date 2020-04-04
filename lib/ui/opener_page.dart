import "dart:async";

import "package:app/ui/router.dart";
import "package:app/widgets/settings_icon_button.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_hooks/flutter_hooks.dart";

class OpenerPage extends HookWidget {
  const OpenerPage();

  @override
  Widget build(BuildContext context) {
    final url = useTextEditingController();

    useEffect(() => url.dispose, []);

    Future<void> paste() async {
      final paste = await Clipboard.getData("text/plain");
      url.text = paste.text;
    }

    void open() {
      if (url.text.isEmpty) {
        return;
      }
      try {
        final uri = Uri.parse(url.value.text);
        Router.of(context).push().reader(url: uri);
      } on FormatException {
        print("Unable to parse ${url.value.text}");
      }
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        title: const Text("Microcosm"),
        centerTitle: false,
        actions: const <Widget>[
          const SettingsIconButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: url,
              autofocus: true,
              autocorrect: false,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                hintText: "Enter your chapter link",
                border: const OutlineInputBorder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 32.0,
                left: 2.0,
                right: 2.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  RaisedButton(
                    onPressed: url.clear,
                    child: const Text("Clear"),
                  ),
                  RaisedButton(
                    onPressed: paste,
                    child: const Text("Paste"),
                  ),
                  RaisedButton(
                    onPressed: open,
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
