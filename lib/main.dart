import 'package:flutter/material.dart';
import 'package:poe_trading_assistant/constants.dart';
import 'package:poe_trading_assistant/providers/test.dart';
import 'package:poe_trading_assistant/screens/screen_start.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SentryFlutter.init(
    (options) {
      options.dsn = Constants.sentryDsn;
    },
    // Init your App.
    appRunner: () => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => TestProvider(),
            lazy: false,
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

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: Constants.appTitle,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const ScreenStart(),
        routes: {
          ScreenStart.routeName: (context) => const ScreenStart(),
        },
        onGenerateRoute: (settings) {
          final ScreenArguments args = settings.arguments as ScreenArguments;

          switch (settings.name) {
            default:
              assert(false, 'Need to implement ${settings.name}');
              return null;
          }
        });
  }
}

class ScreenArguments {
  final String? screenTitle;

  ScreenArguments({
    this.screenTitle,
  });
}
