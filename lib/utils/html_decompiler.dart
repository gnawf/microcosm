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

    // Replace consecutive spaces with one space
    block.innerHtml = block.innerHtml.replaceAll(new RegExp(r"\s{2,}"), " ");

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

  fragment.querySelectorAll("ol").forEach((list) {
    final items = list.querySelectorAll("> li");

    // Add numbers before list items then unwrap them
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final index = new Text("${i + 1}. ");
      item.nodes.insert(0, index);
      unwrap(item);
    }

    // Surround with newlines & unwrap list
    list.nodes.insert(0, new Text("\n\n"));
    list.nodes.add(new Text("\n\n"));
    unwrap(list);
  });

  fragment.querySelectorAll("ul").forEach((list) {
    final items = list.querySelectorAll("> li");

    // Add bullet points before list items then unwrap them
    items.forEach((item) {
      final index = new Text("* ");
      item.nodes.insert(0, index);
      unwrap(item);
    });

    // Surround with newlines & unwrap list
    list.nodes.insert(0, new Text("\n\n"));
    list.nodes.add(new Text("\n\n"));
    unwrap(list);
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
