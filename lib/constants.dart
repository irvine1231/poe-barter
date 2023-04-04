import 'package:flutter/material.dart';
import 'package:screen_retriever/screen_retriever.dart';

class Constants {
  static const debugSw = false; // Should be false when packing release.
  static const appTitle = "POE Barter";
  static const sentryDsn = "https://4d3bf7afcecc49d3a6749a1b5e8c0f60@o251977.ingest.sentry.io/6709325";

  static Size screenSize = const Size(0, 0);
  static Size screenStartSize = const Size(600, 82);
  static Offset screenStartPosition = const Offset(0, 0);
  static Size screenSettingSize = const Size(0, 0);
  static Future<void> initConst() async {
    screenSize = (await screenRetriever.getPrimaryDisplay()).size;

    screenStartPosition = Offset((screenSize.width / 2) - (screenStartSize.width / 2),
        (screenSize.height * 0.93) - (screenStartSize.height / 2));
    screenSettingSize = Size(screenSize.width * 0.5, screenSize.height * 0.5);
  }
}
