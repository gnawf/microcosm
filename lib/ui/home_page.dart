import "package:app/settings/settings.dart";
import "package:app/ui/routes.dart" as routes;
import "package:app/widgets/animated_system_padding.dart";
import "package:flutter/material.dart";

class HomePage extends StatefulWidget {
  @override
  State createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _url = new TextEditingController();

  VoidCallback _dispose;

  void _open() {
    if (_url.text.isNotEmpty) {
      try {
        final url = Uri.parse(_url.text);
        Navigator.of(context).pushReplacement(routes.reader(url: url));
      } on FormatException catch (e) {
        print(e);
      }
    }
  }

  void _updateUrl() {
    final settings = Settings.of(context);
    _url.text = settings.lastChapterUrl;
  }

  @override
  void initState() {
    super.initState();

    final settings = Settings.of(context);
    _url.text = settings.lastChapterUrl;
    // Change the URL automatically
    settings.lastChapterUrlChanges.addListener(_updateUrl);
    _dispose = () {
      settings.lastChapterUrlChanges.removeListener(_updateUrl);
    };
  }

  @override
  void dispose() {
    _url.dispose();
    _dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: null,
        title: const Text("Microcosm"),
        centerTitle: false,
      ),
      body: new AnimatedSystemPadding(
        child: new Padding(
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
      ),
      resizeToAvoidBottomPadding: false,
    );
  }
}
