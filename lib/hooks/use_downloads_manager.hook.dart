import "package:app/downloads/downloads_manager.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:provider/provider.dart";

DownloadsManager useDownloadsManager() {
  final context = useContext();
  return Provider.of(context);
}
