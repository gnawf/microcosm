import "package:app/settings/settings.dart";
import "package:flutter_hooks/flutter_hooks.dart";

SettingsState useSettings() {
  final context = useContext();
  return Settings.of(context);
}
