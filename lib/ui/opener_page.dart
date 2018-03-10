import "dart:async";

import "package:app/settings/settings.dart";
import "package:app/ui/routes.dart" as routes;
import "package:app/widgets/settings_icon_button.dart";
import "package:flutter/material.dart";

class OpenerPage extends StatefulWidget {
  const OpenerPage();

  @override
  State createState() => new _OpenerPageState();
}

class _OpenerPageState extends State<OpenerPage> {
  final TextEditingController _url = new TextEditingController();

  SettingsState _settings;

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

  Future<Null> _updateUrl() async {
    if (!mounted) {
      return;
    }

    final settings = Settings.of(context);
    _url.text = settings.lastChapterUrl;
  }

  @override
  void initState() {
    super.initState();

    _settings = Settings.of(context);
    _url.text = _settings.lastChapterUrl;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _settings = Settings.of(context);
    _settings.lastChapterUrlChanges.addListener(_updateUrl);
  }

  @override
  void deactivate() {
    _settings.lastChapterUrlChanges.removeListener(_updateUrl);
    super.deactivate();
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
            ),
            new Padding(
              padding: const EdgeInsets.only(
                top: 32.0,
              ),
              child: new RaisedButton(
                onPressed: _open,
                child: const Text("Open"),
              ),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomPadding: false,
    );
  }
}
