import "package:html/dom.dart";
import "package:html/parser.dart" as html show parseFragment;

/// Decompiles HTML to markdown
String decompile(String content) {
  final fragment = html.parseFragment(content);

  // Unwrap the paragraphs
  fragment.querySelectorAll("p,div").forEach((block) {
    // If there are no children, simply unwrap by removing the node
    if (block.nodes.isEmpty) {
      block.remove();
      return;
    }

    // Add padding
    block.nodes.insert(0, new Text("\n\n"));
    block.nodes.add(new Text("\n\n"));

    unwrap(block);
  });

  // Replace line breaks with newlines
  fragment.querySelectorAll("br").forEach((br) {
    br.replaceWith(new Text("\n"));
  });

  // Replace em with markdown equivalent
  fragment.querySelectorAll("em").forEach((em) {
    // If there are no children, simply unwrap by removing the node
    if (em.nodes.isEmpty) {
      em.remove();
      return;
    }

    em.nodes.forEach((node) {
      if (node is Text) {
        node.replaceWith(new Text("*${node.text}*"));
      }
    });

    unwrap(em);
  });

  // Replace em with markdown equivalent
  fragment.querySelectorAll("a").forEach((anchor) {
    final text = anchor.text;
    final href = anchor.attributes["href"];
    anchor.replaceWith(new Text("[$text]($href)"));
  });

  // 1. Split by lines
  // 2. Trim lines
  // 3. Remove empty lines
  // 4. Join by an empty line in between
  // Without the invisible character, the newlines are collapsed
  return fragment.text
      .split("\n")
      .map((x) => x.trim())
      .where((x) => x.isNotEmpty)
      .join("\n\n");
}

void unwrap(Node node) {
  final parent = node.parent;
  if (parent != null) {
    final index = parent.nodes.indexOf(node);
    parent.nodes.removeAt(index);
    parent.nodes.insertAll(index, node.nodes);
  }
}
