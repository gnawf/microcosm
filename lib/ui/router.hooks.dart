import "package:app/ui/router.dart";
import "package:flutter_hooks/flutter_hooks.dart";

Router useRouter() {
  final context = useContext();
  return Router.of(context);
}
