import 'package:flutter/material.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:poe_barter/components/action_button.dart';
import 'package:poe_barter/constants.dart';
import 'package:poe_barter/screens/screen_base.dart';
import 'package:poe_barter/screens/screen_start.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

class ScreenTools extends StatefulWidget {
  const ScreenTools({Key? key}) : super(key: key);

  static const routeName = "/tools";

  @override
  State<ScreenTools> createState() => _ScreenToolsState();
}

class _ScreenToolsState extends State<ScreenTools> {
  final double buttonHeight = 100;

  bool showContent = false;

  @override
  void initState() {
    super.initState();

    initWindow();
  }

  Future<void> initWindow() async {
    await windowManager.setIgnoreMouseEvents(false);
    await windowManager.setAlwaysOnTop(false);
    await windowManager.setSize(Constants.screenSettingSize);
    await windowManager.center();
    await windowManager.show();
    setState(() {
      showContent = true;
    });
    await windowManager.focus();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBase(
      body: showContent
          ? Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 300,
                        height: buttonHeight,
                        child: ActionButton(
                          onPressed: () => {
                            launchUrl(
                              Uri.parse('https://poe.ninja/'),
                            )
                          },
                          text: "poe.ninja",
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        height: buttonHeight,
                        child: ActionButton(
                          onPressed: () => {
                            launchUrl(
                              Uri.parse('https://poe.ninja/builds/'),
                            )
                          },
                          text: "poe.ninja Builds",
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 300,
                        height: buttonHeight,
                        child: ActionButton(
                          onPressed: () => {
                            launchUrl(
                              Uri.parse('https://bulk.tftrove.com/'),
                            )
                          },
                          text: "PoE Bulk TFT",
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        height: buttonHeight,
                        child: ActionButton(
                          onPressed: () => {
                            launchUrl(
                              Uri.parse('https://poestack.com/'),
                            )
                          },
                          text: "PoE Stack",
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 300,
                        height: buttonHeight,
                        child: ActionButton(
                          onPressed: () => {
                            launchUrl(
                              Uri.parse('https://poedb.tw/'),
                            )
                          },
                          text: "PoEDB",
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        height: buttonHeight,
                        child: ActionButton(
                          onPressed: () => {
                            launchUrl(
                              Uri.parse('https://www.poelab.com/'),
                            )
                          },
                          text: "PoE Lab",
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 300,
                        height: buttonHeight,
                        child: ActionButton(
                          onPressed: () => {
                            launchUrl(
                              Uri.parse('https://poe.re/#/maps'),
                            )
                          },
                          text: "PoE Regex Maps",
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        height: buttonHeight,
                        child: ActionButton(
                          onPressed: () => {
                            launchUrl(
                              Uri.parse('https://poe.re/#/expedition'),
                            )
                          },
                          text: "PoE Regex Gwennen",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : Container(),
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async {
          setState(() {
            showContent = false;
          });
          navService.pushReplacementNamed(ScreenStart.routeName);
          await windowManager.hide();
        },
      ),
      title: "Tools",
      automaticallyImplyAppBarLeading: false,
    );
  }
}
