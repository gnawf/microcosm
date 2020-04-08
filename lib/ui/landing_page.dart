/// When modifying these values, please consider how it may affect settings
enum LandingPage {
  browse,
  open,
  recents,
  downloads,
}

String landingPageToString(LandingPage page) {
  switch (page) {
    case LandingPage.browse:
      return "Browse";
    case LandingPage.open:
      return "Open";
    case LandingPage.recents:
      return "Recents";
    case LandingPage.downloads:
      return "Downloads";
  }
  throw UnsupportedError("Unknown landing page $page");
}
