import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:poe_barter/constants.dart';
import 'package:poe_barter/providers/auto_update.dart';
import 'package:poe_barter/providers/offer.dart';
import 'package:poe_barter/providers/process.dart';
import 'package:poe_barter/providers/setting.dart';
import 'package:poe_barter/screens/screen_error.dart';
import 'package:poe_barter/screens/screen_setting.dart';
import 'package:poe_barter/screens/screen_start.dart';
import 'package:poe_barter/screens/screen_tools.dart';
import 'package:poe_barter/screens/screen_update.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();
  await Window.setEffect(
    effect: WindowEffect.transparent,
  );

  await initSystemTray();

  await windowManager.ensureInitialized();
  await windowManager.center();
  await Constants.initConst();
  WindowOptions windowOptions = const WindowOptions(
    title: Constants.appTitle,
    titleBarStyle: TitleBarStyle.hidden,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAsFrameless();
  });
  // windowManager.waitUntilReadyToShow(windowOptions, () async {
  //   await windowManager.setPosition(Constants.screenStartPosition);
  //   await windowManager.setAsFrameless();
  //   await windowManager.setAlwaysOnTop(true);
  //   await windowManager.show();
  //   await windowManager.focus();
  //   await windowManager.setIgnoreMouseEvents(true);
  // });

  await SentryFlutter.init(
    (options) {
      options.dsn = Constants.sentryDsn;
    },
    // Init your App.
    appRunner: () => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProcessProvider>(
            create: (_) => ProcessProvider(),
            lazy: false,
          ),
          ChangeNotifierProxyProvider<ProcessProvider, OfferProvider>(
            create: (_) => OfferProvider(),
            lazy: false,
            update: (_, processProvider, offerProvider) => processProvider.offerProvider = offerProvider!,
          ),
          ChangeNotifierProxyProvider<OfferProvider, SettingProvider>(
            create: (_) => SettingProvider(),
            lazy: false,
            update: (_, offerProvider, settingProvider) => offerProvider.settingProvider = settingProvider!,
          ),
          // ChangeNotifierProvider(
          //   create: (_) => UpdateProvider(),
          //   lazy: false,
          // ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

Future<void> initSystemTray() async {
  if (!Platform.isWindows) return;

  final SystemTray systemTray = SystemTray();

  // We first init the systray menu
  await systemTray.initSystemTray(
    title: Constants.appTitle,
    iconPath: "windows/runner/resources/app_icon.ico",
  );

  // create context menu
  final AppWindow appWindow = AppWindow();
  final Menu menu = Menu();
  await menu.buildFrom([
    MenuItemLabel(
      label: 'Setting',
      onClicked: (menuItem) async {
        await windowManager.hide();

        navService.pushReplacementNamed(ScreenSetting.routeName);
      },
    ),
    MenuItemLabel(
      label: 'Tools',
      onClicked: (menuItem) async {
        await windowManager.hide();

        navService.pushReplacementNamed(ScreenTools.routeName);
      },
    ),
    MenuSeparator(),
    MenuItemLabel(
      label: 'Show',
      onClicked: (menuItem) => appWindow.show(),
    ),
    MenuItemLabel(
      label: 'Hide',
      onClicked: (menuItem) => appWindow.hide(),
    ),
    MenuSeparator(),
    MenuItemLabel(
      label: 'Exit',
      onClicked: (menuItem) => appWindow.close(),
    ),
  ]);

  // set context menu
  await systemTray.setContextMenu(menu);

  // handle system tray event
  systemTray.registerSystemTrayEventHandler((eventName) {
    debugPrint("eventName: $eventName");
    if (eventName == kSystemTrayEventClick) {
      Platform.isWindows ? appWindow.show() : systemTray.popUpContextMenu();
    } else if (eventName == kSystemTrayEventRightClick) {
      Platform.isWindows ? systemTray.popUpContextMenu() : appWindow.show();
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: Constants.appTitle,
        navigatorKey: NavigationService.navigationKey,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        color: Colors.transparent,
        home: const ScreenStart(),
        routes: {
          ScreenStart.routeName: (context) => const ScreenStart(),
          ScreenSetting.routeName: (context) => const ScreenSetting(),
          ScreenTools.routeName: (context) => const ScreenTools(),
          ScreenUpdate.routeName: (context) => const ScreenUpdate(),
        },
        onGenerateRoute: (settings) {
          final ScreenArguments args = settings.arguments as ScreenArguments;

          switch (settings.name) {
            case ScreenError.routeName:
              return MaterialPageRoute(
                builder: (context) {
                  return ScreenError(
                    errorMsg: args.errorMsg ?? '',
                  );
                },
              );

            default:
              assert(false, 'Need to implement ${settings.name}');
              return null;
          }
        });
  }
}

class ScreenArguments {
  final String? screenTitle;
  final String? errorMsg;

  ScreenArguments({
    this.screenTitle,
    this.errorMsg,
  });

  static ScreenArguments fromJson(Map<String, String> args) => ScreenArguments(
        screenTitle: args['screenTitle'],
        errorMsg: args['errorMsg'],
      );
}
