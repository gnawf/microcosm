import "dart:async";

import "package:app/dialogs/message_dialog.dart";
import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

Future<Null> onTapLink(BuildContext context, String url) async {
  // Deep linking
  Uri uri;
  try {
    uri = Uri.parse(url);
  } on FormatException {
    print("Unable to parse $url for deep linking");
  }
  if (uri != null && _deepLink(context, uri)) {
    return;
  }

  // Launch in browser
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    final scaffold = Scaffold.of(context, nullOk: true);
    if (scaffold != null) {
      const text = const Text("Unable to open link");
      scaffold.showSnackBar(const SnackBar(content: text));
    }
  }
}

bool _deepLink(BuildContext context, Uri uri) {
  if (uri.pathSegments.isEmpty) {
    return false;
  }

  switch (uri.pathSegments[0]) {
    case "dialog":
      showMessageDialog(
        context: context,
        title: uri.queryParameters["title"]?.trim(),
        content: uri.queryParameters["content"]?.trim(),
      );
      return true;
  }
  return false;
}
