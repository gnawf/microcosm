import "package:app/ui/router.dart";
import "package:flutter_hooks/flutter_hooks.dart";

Router useRouter({bool rootNavigator = false, bool nullOk = false}) {
  final context = useContext();
  return Router.of(context, rootNavigator: rootNavigator, nullOk: nullOk);
}
