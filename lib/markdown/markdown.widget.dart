// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_markdown/flutter_markdown.dart";
import "package:markdown/markdown.dart" as md;
import "package:meta/meta.dart";

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
  _PerformantMarkdownWidgetState createState() => _PerformantMarkdownWidgetState();
}

class _PerformantMarkdownWidgetState extends State<PerformantMarkdownWidget> implements MarkdownBuilderDelegate {
  List<Widget> _children;
  List<md.Node> _markdownNodes;
  MarkdownBuilder _markdownBuilder;
  final List<GestureRecognizer> _recognizers = <GestureRecognizer>[];

  @override
  void initState() {
    super.initState();
    _markdownBuilder = _newMarkdownBuilder();
    _parseMarkdown();
  }

  @override
  void didUpdateWidget(PerformantMarkdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectable != oldWidget.selectable ||
        widget.styleSheet != oldWidget.styleSheet ||
        widget.imageDirectory != oldWidget.imageDirectory ||
        widget.imageBuilder != oldWidget.imageBuilder ||
        widget.checkboxBuilder != oldWidget.checkboxBuilder ||
        widget.fitContent != oldWidget.fitContent) {
      _markdownBuilder = _newMarkdownBuilder();
    }
    if (widget.data != oldWidget.data) {
      _parseMarkdown();
    }
    if (widget.styleSheet != oldWidget.styleSheet) {
      _renderMarkdown();
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  MarkdownBuilder _newMarkdownBuilder() {
    return MarkdownBuilder(
      delegate: this,
      selectable: widget.selectable,
      styleSheet: widget.styleSheet,
      imageDirectory: widget.imageDirectory,
      imageBuilder: widget.imageBuilder,
      checkboxBuilder: widget.checkboxBuilder,
      fitContent: widget.fitContent,
    );
  }

  Future<void> _parseMarkdown() async {
    _renderMarkdown(
      // Expensive operation – see [_isolateParseMarkdown] for more info
      _markdownNodes = await compute(_isolateParseMarkdown, widget.data),
    );
  }

  void _renderMarkdown([List<md.Node> nodes]) {
    nodes ??= _markdownNodes;

    if (nodes == null) {
      return;
    }

    setState(() {
      // Not so expensive operation that is much harder to run in isolate
      _children = _markdownBuilder.build(nodes);
    });
  }

  void _disposeRecognizers() {
    if (_recognizers.isEmpty) return;
    final localRecognizers = List<GestureRecognizer>.from(_recognizers);
    _recognizers.clear();
    for (final recognizer in localRecognizers) recognizer.dispose();
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

/// So this is actually a very expensive operation (see below) so we compute it in an isolate
/// Running in an isolate actually takes magnitudes longer but for UI smoothness this is better
/// In the release (AOT compilation) build this is very slow due to RegExp performance, see:
/// https://github.com/dart-lang/sdk/issues/39260
/// https://github.com/dart-lang/sdk/issues/37774
/// https://github.com/dart-lang/sdk/issues/39139
List<md.Node> _isolateParseMarkdown(String data) {
  final lines = data.split(RegExp(r"\r?\n"));
  final document = md.Document(
    extensionSet: md.ExtensionSet.gitHubFlavored,
    inlineSyntaxes: [TaskListSyntax()],
    encodeHtml: false,
  );
  return document.parseLines(lines);
}
