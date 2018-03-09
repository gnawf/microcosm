import "package:html/dom.dart";

void unwrap(Node node) {
  final parent = node.parent;
  if (parent != null) {
    final index = parent.nodes.indexOf(node);
    parent.nodes.removeAt(index);
    parent.nodes.insertAll(index, node.nodes);
  }
}

void traverse(Node ancestor, void step(Node node)) {
  ancestor.nodes.forEach((child) {
    step(child);
    if (child.nodes.isNotEmpty) {
      child.nodes.forEach((descendant) {
        step(descendant);
        traverse(descendant, step);
      });
    }
  });
}
