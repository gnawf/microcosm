import "package:app/ui/router.dart";
import "package:flutter_hooks/flutter_hooks.dart";

AppRouter useRouter({bool rootNavigator = false, bool nullOk = false}) {
  final context = useContext();
  return AppRouter.of(context, rootNavigator: rootNavigator, nullOk: nullOk);
}
