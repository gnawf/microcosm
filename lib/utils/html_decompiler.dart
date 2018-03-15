import "package:app/utils/html_utils.dart" as utils;
import "package:html/dom.dart";
import "package:html/parser.dart" as html show parseFragment;

/// Decompiles HTML to markdown
String decompile(String content, [Uri source]) {
  // Zero width joiner character; this is used to allow formatting mid word
  // As per https://meta.stackexchange.com/q/140706
  final zwj = new String.fromCharCode(8205);

  final fragment = html.parseFragment(content);

  // Unwrap the paragraphs
  fragment.querySelectorAll("p,div").forEach((block) {
    // If there are no children, simply unwrap by removing the node
    if (block.nodes.isEmpty) {
      block.remove();
      return;
    }

    // Replace consecutive spaces with one space
    block.innerHtml = block.innerHtml.replaceAll(new RegExp(r"\s{2,}"), " ");

    // Add padding
    block.nodes.insert(0, new Text("\n"));
    block.nodes.add(new Text("\n"));

    utils.unwrap(block);
  });

  // Replace line breaks with newlines
  fragment.querySelectorAll("br").forEach((br) {
    br.replaceWith(new Text("\n"));
  });

  // Replace text formatting with markdown equivalent
  fragment.querySelectorAll("em,b,strong").forEach((text) {
    // If there are no children, simply unwrap by removing the node
    if (text.nodes.isEmpty) {
      text.remove();
      return;
    }

    utils.traverse(text, (node) {
      if (node is Text) {
        switch (text.localName) {
          case "b":
          case "strong":
            node.replaceWith(new Text("${zwj}__${node.text}__$zwj"));
            break;
          case "em":
            node.replaceWith(new Text("${zwj}_${node.text}_$zwj"));
            break;
        }
      }
    });

    utils.unwrap(text);
  });

  // Replace em with markdown equivalent
  fragment.querySelectorAll("a[href]").forEach((anchor) {
    final text = anchor.text.trim();
    // Ignore if there is no text i.e. link is invalid
    if (text.isEmpty) {
      return;
    }
    final href = anchor.attributes["href"];
    final link = source?.resolve(href)?.toString() ?? href;
    anchor.replaceWith(new Text("[$text]($link)"));
  });

  fragment.querySelectorAll("ol").forEach((list) {
    final items = list.querySelectorAll("> li");

    // Add numbers before list items then unwrap them
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final index = new Text("${i + 1}. ");
      item.nodes.insert(0, index);
      utils.unwrap(item);
    }

    // Surround with newlines & unwrap list
    list.nodes.insert(0, new Text("\n"));
    list.nodes.add(new Text("\n"));
    utils.unwrap(list);
  });

  fragment.querySelectorAll("ul").forEach((list) {
    // Add bullet points before list items then unwrap them
    list.querySelectorAll("> li").forEach((item) {
      final index = new Text("* ");
      item.nodes.insert(0, index);
      utils.unwrap(item);
    });

    // Surround with newlines & unwrap list
    list.nodes.insert(0, new Text("\n"));
    list.nodes.add(new Text("\n"));
    utils.unwrap(list);
  });

  // 1. Split by lines
  // 2. Trim lines
  // 3. Remove empty lines
  // 4. Join by an empty line in between
  // Without the invisible character, the newlines are collapsed
  return fragment.text
      .split("\n")
      .map(_trim)
      .where((x) => x.isNotEmpty)
      .join("\n\n");
}

String _trim(String text) {
  // Remove any whitespace and keep random characters
  return text.replaceAllMapped(new RegExp(r"^[^a-zA-Z0-9]+"), (match) {
    // If there's no text in the line, remove it
    if (match[0].length == text.length) {
      return "";
    }

    // Preserve whitespace for lists
    if (match[0].startsWith("* ")) {
      return match[0].replaceAll(new RegExp(r"\s{2,}"), " ");
    }
    return match[0].replaceAll(new RegExp(r"\s+"), "");
  }).replaceAllMapped(new RegExp(r"[^a-zA-Z0-9]+$"), (match) {
    return match[0].replaceAll(new RegExp(r"\s+"), "");
  });
}
