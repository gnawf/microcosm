import "package:app/providers/database_provider.dart";
import "package:flutter_hooks/flutter_hooks.dart";

DatabaseProviderState useDatabaseProvider() {
  final context = useContext();
  return DatabaseProvider.of(context);
}
