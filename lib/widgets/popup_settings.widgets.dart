part of "popup_settings.dart";

class _DarkThemeSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Settings.of(context);

    return CheckboxListTile(
      value: settings.brightness == Brightness.dark,
      onChanged: (value) {
        settings.brightness = value ? Brightness.dark : Brightness.light;
      },
      title: const Text("Dark Theme"),
      secondary: const Icon(MDIcons.weatherNight),
    );
  }
}

class _AmoledSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Settings.of(context);

    return CheckboxListTile(
      value: settings.amoled,
      onChanged: settings.brightness == Brightness.dark ? (value) => settings.amoled = value : null,
      title: const Text("Amoled Mode"),
      secondary: const Icon(MDIcons.imageFilterBlackWhite),
    );
  }
}

class _PrimaryColorSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Settings.of(context);

    return ListTile(
      leading: const Icon(MDIcons.palette),
      title: const Text("Primary Color"),
      trailing: _TrailingColorIndicator(
        color: settings.primarySwatch,
      ),
      onTap: () async {
        final color = await openPrimarySwatchPicker(
          context,
          selected: settings.primarySwatch,
        );
        if (color != null) {
          settings.primarySwatch = color;
        }
      },
    );
  }
}

class _AccentColorSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Settings.of(context);

    return ListTile(
      leading: const Icon(MDIcons.eyedropper),
      title: const Text("Accent Color"),
      trailing: _TrailingColorIndicator(
        color: settings.accentColor,
      ),
      onTap: () async {
        final color = await openAccentColorPicker(
          context,
          selected: settings.accentColor,
        );
        if (color != null) {
          settings.accentColor = color;
        }
      },
    );
  }
}

class _TrailingColorIndicator extends StatelessWidget {
  _TrailingColorIndicator({this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 10,
      ),
      child: Container(
        width: 18.0,
        height: 18.0,
        color: color,
      ),
    );
  }
}

class _ReaderFontSizeSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Settings.of(context);

    return ListTile(
      leading: const Icon(MDIcons.formatFont),
      title: const Text("Reader Font Size"),
      trailing: Text("${settings.readerFontSize}px"),
      onTap: () async {
        final value = await showFontSizePickerDialog(
          context: context,
          title: const Text("Reader Font Size"),
          min: 8.0,
          max: 24.0,
          value: settings.readerFontSize,
          defaultValue: settings.defaultReaderFontSize,
        );
        if (value != null) {
          settings.readerFontSize = value;
        }
      },
    );
  }
}

class _LandingPageSetting extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Settings.of(context);
    final setting = useState(settings.landingPage);

    useEffect(() => () => settings.landingPage = setting.value, []);

    return ListTile(
      leading: const Icon(MDIcons.home),
      title: const Text("Home Page"),
      trailing: DropdownButton<LandingPage>(
        items: [
          for (final page in LandingPage.values)
            DropdownMenuItem(
              value: page,
              child: _landingPageToText(page),
            ),
        ],
        value: setting.value,
        onChanged: (LandingPage page) {
          setting.value = page;
        },
      ),
    );
  }
}

Text _landingPageToText(LandingPage page) {
  switch (page) {
    case LandingPage.browse:
      return const Text("Browse");
    case LandingPage.open:
      return const Text("Open");
    case LandingPage.recents:
      return const Text("Recents");
    case LandingPage.downloads:
      return const Text("Downloads");
  }

  throw UnsupportedError("Unknown landing page $page");
}

class _ReaderAlignmentSetting extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Settings.of(context);
    final setting = useState(settings.readerAlignment);
    const supportedValues = const [
      WrapAlignment.start,
      WrapAlignment.end,
      WrapAlignment.center,
      WrapAlignment.spaceBetween,
    ];

    return ListTile(
      leading: const Icon(MDIcons.formatAlignLeft),
      title: const Text("Reader Text"),
      trailing: DropdownButton<WrapAlignment>(
        items: [
          for (final page in supportedValues)
            DropdownMenuItem(
              value: page,
              child: _wrapAlignmentToText(page),
            ),
        ],
        value: setting.value,
        onChanged: (WrapAlignment alignment) {
          setting.value = alignment;
          settings.readerAlignment = alignment;
        },
      ),
    );
  }
}

Text _wrapAlignmentToText(WrapAlignment alignment) {
  switch (alignment) {
    case WrapAlignment.start:
      return const Text("Start");
    case WrapAlignment.end:
      return const Text("End");
    case WrapAlignment.center:
      return const Text("Center");
    case WrapAlignment.spaceBetween:
      return const Text("Justify");
    case WrapAlignment.spaceAround:
      return const Text("Space Around");
    case WrapAlignment.spaceEvenly:
      return const Text("Space Evenly");
  }

  throw UnsupportedError("Unknown landing page $alignment");
}
