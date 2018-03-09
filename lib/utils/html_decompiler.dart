import "package:html/dom.dart";
import "package:html/parser.dart" as html show parseFragment;

/// Decompiles HTML to markdown
String decompile(String content) {
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
    block.nodes.insert(0, new Text("\n\n"));
    block.nodes.add(new Text("\n\n"));

    _unwrap(block);
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

    _traverse(text, (node) {
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

    _unwrap(text);
  });

  // Replace em with markdown equivalent
  fragment.querySelectorAll("a").forEach((anchor) {
    final text = anchor.text;
    final href = anchor.attributes["href"];
    anchor.replaceWith(new Text("[$text]($href)"));
  });

  fragment.querySelectorAll("ol").forEach((list) {
    final items = list.querySelectorAll("> li");

    // Add numbers before list items then unwrap them
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final index = new Text("${i + 1}. ");
      item.nodes.insert(0, index);
      _unwrap(item);
    }

    // Surround with newlines & unwrap list
    list.nodes.insert(0, new Text("\n\n"));
    list.nodes.add(new Text("\n\n"));
    _unwrap(list);
  });

  fragment.querySelectorAll("ul").forEach((list) {
    final items = list.querySelectorAll("> li");

    // Add bullet points before list items then unwrap them
    items.forEach((item) {
      final index = new Text("* ");
      item.nodes.insert(0, index);
      _unwrap(item);
    });

    // Surround with newlines & unwrap list
    list.nodes.insert(0, new Text("\n\n"));
    list.nodes.add(new Text("\n\n"));
    _unwrap(list);
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

void _unwrap(Node node) {
  final parent = node.parent;
  if (parent != null) {
    final index = parent.nodes.indexOf(node);
    parent.nodes.removeAt(index);
    parent.nodes.insertAll(index, node.nodes);
  }
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

void _traverse(Node ancestor, void step(Node node)) {
  ancestor.nodes.forEach((child) {
    step(child);
    if (child.nodes.isNotEmpty) {
      child.nodes.forEach((descendant) {
        step(descendant);
        _traverse(descendant, step);
      });
    }
  });
}
