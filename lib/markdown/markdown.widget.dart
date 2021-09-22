// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "dart:convert";
import "dart:io";

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
///  * [MarkdownBody], which is a non-scrolling container of Markdown.
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
    this.onTapText,
    this.imageDirectory,
    this.blockSyntaxes,
    this.inlineSyntaxes,
    this.extensionSet,
    this.imageBuilder,
    this.checkboxBuilder,
    this.bulletBuilder,
    this.builders = const <String, MarkdownElementBuilder>{},
    this.fitContent = false,
    this.listItemCrossAxisAlignment = MarkdownListItemCrossAxisAlignment.baseline,
    this.softLineBreak = false,
  }) : super(key: key);

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

  /// Default tap handler used when [selectable] is set to true
  final VoidCallback onTapText;

  /// The base directory holding images referenced by Img tags with local or network file paths.
  final String imageDirectory;

  /// Collection of custom block syntax types to be used parsing the Markdown data.
  final List<md.BlockSyntax> blockSyntaxes;

  /// Collection of custom inline syntax types to be used parsing the Markdown data.
  final List<md.InlineSyntax> inlineSyntaxes;

  /// Markdown syntax extension set
  ///
  /// Defaults to [md.ExtensionSet.gitHubFlavored]
  final md.ExtensionSet extensionSet;

  /// Call when build an image widget.
  final MarkdownImageBuilder imageBuilder;

  /// Call when build a checkbox widget.
  final MarkdownCheckboxBuilder checkboxBuilder;

  /// Called when building a bullet
  final MarkdownBulletBuilder bulletBuilder;

  /// Render certain tags, usually used with [extensionSet]
  ///
  /// For example, we will add support for `sub` tag:
  ///
  /// ```dart
  /// builders: {
  ///   'sub': SubscriptBuilder(),
  /// }
  /// ```
  ///
  /// The `SubscriptBuilder` is a subclass of [MarkdownElementBuilder].
  final Map<String, MarkdownElementBuilder> builders;

  /// Whether to allow the widget to fit the child content.
  final bool fitContent;

  /// Controls the cross axis alignment for the bullet and list item content
  /// in lists.
  ///
  /// Defaults to [MarkdownListItemCrossAxisAlignment.baseline], which
  /// does not allow for intrinsic height measurements.
  final MarkdownListItemCrossAxisAlignment listItemCrossAxisAlignment;

  /// The soft line break is used to identify the spaces at the end of aline of
  /// text and the leading spaces in the immediately following the line of text.
  ///
  /// Default these spaces are removed in accordance with the Markdown
  /// specification on soft line breaks when lines of text are joined.
  final bool softLineBreak;

  /// Subclasses should override this function to display the given children,
  /// which are the parsed representation of [data].
  @protected
  Widget build(BuildContext context, List<Widget> children);

  @override
  _PerformantMarkdownWidgetState createState() => _PerformantMarkdownWidgetState();
}

class _PerformantMarkdownWidgetState extends State<PerformantMarkdownWidget> implements MarkdownBuilderDelegate {
  List<Widget> _children;
  final List<GestureRecognizer> _recognizers = <GestureRecognizer>[];

  @override
  void didChangeDependencies() {
    _parseMarkdown();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(PerformantMarkdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data || widget.styleSheet != oldWidget.styleSheet) {
      _parseMarkdown();
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _parseMarkdown() {
    final MarkdownStyleSheet fallbackStyleSheet = _kFallbackStyle(context, widget.styleSheetTheme);
    final MarkdownStyleSheet styleSheet = fallbackStyleSheet.merge(widget.styleSheet);

    _disposeRecognizers();

    // Parse the source Markdown data into nodes of an Abstract Syntax Tree.
    final astNodes = _isolateParseMarkdown(widget.data);

    // Configure a Markdown widget builder to traverse the AST nodes and
    // create a widget tree based on the elements.
    final MarkdownBuilder builder = MarkdownBuilder(
      delegate: this,
      selectable: widget.selectable,
      styleSheet: styleSheet,
      imageDirectory: widget.imageDirectory,
      imageBuilder: widget.imageBuilder,
      checkboxBuilder: widget.checkboxBuilder,
      bulletBuilder: widget.bulletBuilder,
      builders: widget.builders,
      fitContent: widget.fitContent,
      listItemCrossAxisAlignment: widget.listItemCrossAxisAlignment,
      onTapText: widget.onTapText,
      softLineBreak: widget.softLineBreak,
    );

    _children = builder.build(astNodes);
  }

  void _disposeRecognizers() {
    if (_recognizers.isEmpty) {
      return;
    }
    final List<GestureRecognizer> localRecognizers = List<GestureRecognizer>.from(_recognizers);
    _recognizers.clear();
    for (final GestureRecognizer recognizer in localRecognizers) recognizer.dispose();
  }

  @override
  GestureRecognizer createLink(String text, String href, String title) {
    final TapGestureRecognizer recognizer = TapGestureRecognizer()
      ..onTap = () {
        if (widget.onTapLink != null) {
          widget.onTapLink(text, href, title);
        }
      };
    _recognizers.add(recognizer);
    return recognizer;
  }

  @override
  TextSpan formatText(MarkdownStyleSheet styleSheet, String code) {
    code = code.replaceAll(RegExp(r'\n$'), '');
    if (widget.syntaxHighlighter != null) {
      return widget.syntaxHighlighter.format(code);
    }
    return TextSpan(style: styleSheet.code, text: code);
  }

  @override
  Widget build(BuildContext context) => widget.build(context, _children);
}

final MarkdownStyleSheet Function(BuildContext, MarkdownStyleSheetBaseTheme) _kFallbackStyle = (
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

/// So this is actually a very expensive operation (see below) so we compute it in an isolate
/// Running in an isolate actually takes magnitudes longer but for UI smoothness this is better
/// In the release (AOT compilation) build this is very slow due to RegExp performance, see:
/// https://github.com/dart-lang/sdk/issues/39260
/// https://github.com/dart-lang/sdk/issues/37774
/// https://github.com/dart-lang/sdk/issues/39139
List<md.Node> _isolateParseMarkdown(String data) {
  final document = md.Document(
    extensionSet: md.ExtensionSet.gitHubFlavored,
    inlineSyntaxes: [TaskListSyntax()],
    encodeHtml: false,
  );
  final List<String> lines = const LineSplitter().convert(data);
  return document.parseLines(lines);
}
