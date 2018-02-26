import "package:app/models/chapter.dart";
import "package:app/navigation/transitions.dart";
import "package:app/ui/home_page.dart";
import "package:app/ui/reader_page.dart";
import "package:flutter/material.dart";

Route home() {
  return new CupertinoPageRoute(
    settings: const RouteSettings(name: "home"),
    builder: (BuildContext context) => new HomePage(),
  );
}

Route reader({Uri url}) {
  final slug = slugify(uri: url);

  return new CupertinoPageRoute(
    settings: new RouteSettings(name: "reader/$slug"),
    builder: (BuildContext context) => new ReaderPage(url),
  );
}
