import "package:html/dom.dart";

void unwrap(Node node) {
  final parent = node.parent;
  if (parent != null) {
    final index = parent.nodes.indexOf(node);
    parent.nodes.removeAt(index);
    parent.nodes.insertAll(index, node.nodes);
  }
}

bool traverse(Node ancestor, bool step(Node node)) {
  for (final child in ancestor.nodes) {
    if (step(child) == false) {
      return false;
    }
    // In case traversal step removes child
    if (child.parent == null) {
      continue;
    }
    for (final descendant in child.nodes) {
      if (step(descendant) == false) {
        return false;
      }
      // In case traversal step removes descendant
      if (descendant.parent != null && traverse(descendant, step) == false) {
        return false;
      }
    }
  }

  return true;
}
