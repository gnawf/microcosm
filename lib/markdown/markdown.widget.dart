// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "dart:io";

import "package:flutter/cupertino.dart";
import 'package:flutter/foundation.dart';
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_markdown/flutter_markdown.dart";
import "package:markdown/markdown.dart" as md;
import "package:meta/meta.dart";

final MarkdownStyleSheet Function(BuildContext, MarkdownStyleSheetBaseTheme)
    kFallbackStyle = (
  BuildContext context,
  MarkdownStyleSheetBaseTheme baseTheme,
) {
  switch (baseTheme) {
    case MarkdownStyleSheetBaseTheme.platform:
      return (Platform.isIOS || Platform.isMacOS)
          ? MarkdownStyleSheet.fromCupertinoTheme(CupertinoTheme.of(context))
          : MarkdownStyleSheet.fromTheme(Theme.of(context));
    case MarkdownStyleSheetBaseTheme.cupertino:
      return MarkdownStyleSheet.fromCupertinoTheme(CupertinoTheme.of(context));
    case MarkdownStyleSheetBaseTheme.material:
    default:
      return MarkdownStyleSheet.fromTheme(Theme.of(context));
  }
};

/// Signature for callbacks used by [PerformantMarkdownWidget] when the user taps a link.
///
/// Used by [PerformantMarkdownWidget.onTapLink].
typedef void MarkdownTapLinkCallback(String href);

/// Signature for custom image widget.
///
/// Used by [PerformantMarkdownWidget.imageBuilder]
typedef Widget MarkdownImageBuilder(Uri uri);

/// Signature for custom checkbox widget.
///
/// Used by [PerformantMarkdownWidget.checkboxBuilder]
typedef Widget MarkdownCheckboxBuilder(bool value);

/// Creates a format [TextSpan] given a string.
///
/// Used by [PerformantMarkdownWidget] to highlight the contents of `pre` elements.
abstract class SyntaxHighlighter {
  // ignore: one_member_abstracts
  /// Returns the formatted [TextSpan] for the given string.
  TextSpan format(String source);
}

/// Enum to specify which theme being used when creating [MarkdownStyleSheet]
///
/// [material] - create MarkdownStyleSheet based on MaterialTheme
/// [cupertino] - create MarkdownStyleSheet based on CupertinoTheme
/// [platform] - create MarkdownStyleSheet based on the Platform where the
/// is running on. Material on Android and Cupertino on iOS
enum MarkdownStyleSheetBaseTheme { material, cupertino, platform }

/// A base class for widgets that parse and display Markdown.
///
/// Supports all standard Markdown from the original
/// [Markdown specification](https://github.github.com/gfm/).
///
/// See also:
///
///  * [Markdown], which is a scrolling container of Markdown.
///  * [PerformantMarkdownBody], which is a non-scrolling container of Markdown.
///  * <https://github.github.com/gfm/>
abstract class PerformantMarkdownWidget extends StatefulWidget {
  /// Creates a widget that parses and displays Markdown.
  ///
  /// The [data] argument must not be null.
  const PerformantMarkdownWidget({
    Key key,
    @required this.data,
    this.selectable = false,
    this.styleSheet,
    this.styleSheetTheme = MarkdownStyleSheetBaseTheme.material,
    this.syntaxHighlighter,
    this.onTapLink,
    this.imageDirectory,
    this.imageBuilder,
    this.checkboxBuilder,
    this.fitContent = false,
  })  : assert(data != null),
        assert(selectable != null),
        super(key: key);

  /// The Markdown to display.
  final String data;

  /// If true, the text is selectable.
  ///
  /// Defaults to false.
  final bool selectable;

  /// The styles to use when displaying the Markdown.
  ///
  /// If null, the styles are inferred from the current [Theme].
  final MarkdownStyleSheet styleSheet;

  /// Setting to specify base theme for MarkdownStyleSheet
  ///
  /// Default to [MarkdownStyleSheetBaseTheme.material]
  final MarkdownStyleSheetBaseTheme styleSheetTheme;

  /// The syntax highlighter used to color text in `pre` elements.
  ///
  /// If null, the [MarkdownStyleSheet.code] style is used for `pre` elements.
  final SyntaxHighlighter syntaxHighlighter;

  /// Called when the user taps a link.
  final MarkdownTapLinkCallback onTapLink;

  /// The base directory holding images referenced by Img tags with local or network file paths.
  final String imageDirectory;

  /// Call when build an image widget.
  final MarkdownImageBuilder imageBuilder;

  /// Call when build a checkbox widget.
  final MarkdownCheckboxBuilder checkboxBuilder;

  /// Whether to allow the widget to fit the child content.
  final bool fitContent;

  /// Subclasses should override this function to display the given children,
  /// which are the parsed representation of [data].
  @protected
  Widget build(BuildContext context, List<Widget> children);

  @override
  _PerformantMarkdownWidgetState createState() =>
      _PerformantMarkdownWidgetState();
}

class _PerformantMarkdownWidgetState extends State<PerformantMarkdownWidget>
    implements MarkdownBuilderDelegate {
  List<Widget> _children;
  final List<GestureRecognizer> _recognizers = <GestureRecognizer>[];

  @override
  void initState() {
    super.initState();
    _parseMarkdown();
  }

  @override
  void didUpdateWidget(PerformantMarkdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data ||
        widget.styleSheet != oldWidget.styleSheet) {
      _parseMarkdown();
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  Future<void> _parseMarkdown() async {
    await null;

    final MarkdownStyleSheet fallbackStyleSheet =
        kFallbackStyle(context, widget.styleSheetTheme);
    final MarkdownStyleSheet styleSheet =
        fallbackStyleSheet.merge(widget.styleSheet);

    _disposeRecognizers();

    final List<String> lines = widget.data.split(RegExp(r"\r?\n"));
    final MarkdownBuilder builder = MarkdownBuilder(
      delegate: this,
      selectable: widget.selectable,
      styleSheet: styleSheet,
      imageDirectory: widget.imageDirectory,
      imageBuilder: widget.imageBuilder,
      checkboxBuilder: widget.checkboxBuilder,
      fitContent: widget.fitContent,
    );

    // Expensive operation
    final nodes = await compute(_isolateParseMarkdown, lines);

    setState(() {
      // Not so expensive operation that is much harder to run in isolate
      _children = builder.build(nodes);
    });
  }

  void _disposeRecognizers() {
    if (_recognizers.isEmpty) return;
    final List<GestureRecognizer> localRecognizers =
        List<GestureRecognizer>.from(_recognizers);
    _recognizers.clear();
    for (GestureRecognizer recognizer in localRecognizers) recognizer.dispose();
  }

  @override
  GestureRecognizer createLink(String href) {
    final TapGestureRecognizer recognizer = TapGestureRecognizer()
      ..onTap = () {
        if (widget.onTapLink != null) widget.onTapLink(href);
      };
    _recognizers.add(recognizer);
    return recognizer;
  }

  @override
  TextSpan formatText(MarkdownStyleSheet styleSheet, String code) {
    code = code.replaceAll(RegExp(r"\n$"), "");
    if (widget.syntaxHighlighter != null) {
      return widget.syntaxHighlighter.format(code);
    }
    return TextSpan(style: styleSheet.code, text: code);
  }

  @override
  Widget build(BuildContext context) => widget.build(context, _children);
}

/// Parse [task list items](https://github.github.com/gfm/#task-list-items-extension-).
class TaskListSyntax extends md.InlineSyntax {
  TaskListSyntax() : super(_pattern);

  // FIXME: Waiting for dart-lang/markdown#269 to land
  static const String _pattern = r"^ *\[([ xX])\] +";

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    md.Element el = md.Element.withTag("input");
    el.attributes["type"] = "checkbox";
    el.attributes["disabled"] = "true";
    el.attributes["checked"] = "${match[1].trim().isNotEmpty}";
    parser.addNode(el);
    return true;
  }
}

/// So this is actually a very expensive operation so we compute it in an isolate
List<md.Node> _isolateParseMarkdown(List<String> lines) {
  final document = md.Document(
    extensionSet: md.ExtensionSet.gitHubFlavored,
    inlineSyntaxes: [TaskListSyntax()],
    encodeHtml: false,
  );
  return document.parseLines(lines);
}
