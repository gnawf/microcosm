import "package:app/persistence/persistence.dart";
import "package:flutter/material.dart";
import "package:meta/meta.dart";

class PersistenceProvider extends StatefulWidget {
  const PersistenceProvider({@required this.child});

  final Widget child;

  static PersistenceProviderState of(BuildContext context) {
    const matcher = const TypeMatcher<PersistenceProviderState>();
    return context.ancestorStateOfType(matcher);
  }

  @override
  State createState() => new PersistenceProviderState();
}

class PersistenceProviderState extends State<PersistenceProvider> {
  final persistence = new Persistence();

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
