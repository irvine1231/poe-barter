import 'package:flutter/material.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:poe_barter/constants.dart';
import 'package:poe_barter/screens/screen_base.dart';
import 'package:poe_barter/screens/screen_start.dart';
import 'package:window_manager/window_manager.dart';

class ScreenSetting extends StatefulWidget {
  const ScreenSetting({Key? key}) : super(key: key);

  static const routeName = "/setting";

  @override
  State<ScreenSetting> createState() => _ScreenSettingState();
}

class _ScreenSettingState extends State<ScreenSetting> {
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
    await windowManager.focus();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBase(
      body: Expanded(
        child: Container(),
      ),
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async {
          navService.pushReplacementNamed(ScreenStart.routeName);
          await windowManager.hide();
        },
      ),
      title: "Setting",
      automaticallyImplyAppBarLeading: false,
    );
  }
}
