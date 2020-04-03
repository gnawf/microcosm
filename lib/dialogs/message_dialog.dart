import "dart:async";

import "package:app/utils/url_launcher.dart" as urls;
import "package:flutter/material.dart";
import "package:flutter_markdown/flutter_markdown.dart";
import "package:markdown/markdown.dart" as md;

Future<Null> showMessageDialog({
  BuildContext context,
  String title,
  String content,
  bool markdown = true,
}) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return new AlertDialog(
        title: title != null ? new Text(title) : null,
        content: content != null ? new _Content(context, content) : null,
      );
    },
  );
}

class _Content extends MarkdownWidget {
  _Content(
    BuildContext context,
    String data, {
    Key key,
    bool selectable = false,
    MarkdownStyleSheet styleSheet,
    MarkdownStyleSheetBaseTheme styleSheetTheme = MarkdownStyleSheetBaseTheme.material,
    SyntaxHighlighter syntaxHighlighter,
    MarkdownTapLinkCallback onTapLink,
    String imageDirectory,
    md.ExtensionSet extensionSet,
    MarkdownImageBuilder imageBuilder,
    MarkdownCheckboxBuilder checkboxBuilder,
    bool fitContent,
  }) : super(
          key: key,
          data: data,
          styleSheet: styleSheet ?? defaultStyleSheet(context),
          syntaxHighlighter: syntaxHighlighter,
          onTapLink: (link) => urls.onTapLink(context, link),
          imageDirectory: imageDirectory,
        );

  static MarkdownStyleSheet defaultStyleSheet(BuildContext context) {
    final theme = Theme.of(context);
    final ss = new MarkdownStyleSheet.fromTheme(theme);
    return ss.copyWith(
      p: ss.p.copyWith(fontSize: 15.0),
    );
  }

  @override
  Widget build(BuildContext context, List<Widget> children) {
    return new Padding(
      padding: const EdgeInsets.only(
        top: 4.0,
      ),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
