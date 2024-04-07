import 'package:flutter/material.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:poe_barter/constants.dart';
import 'package:poe_barter/providers/auto_update.dart';
import 'package:poe_barter/screens/screen_base.dart';
import 'package:poe_barter/screens/screen_start.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class ScreenUpdate extends StatefulWidget {
  static const routeName = "/update";

  const ScreenUpdate({super.key});

  @override
  State<ScreenUpdate> createState() => _ScreenUpdateState();
}

class _ScreenUpdateState extends State<ScreenUpdate> {
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
          ? Column(
              children: [
                if (Provider.of<UpdateProvider?>(context) != null &&
                    Provider.of<UpdateProvider>(context).newVersionDownloaded)
                  Container(
                    width: double.infinity,
                    color: Colors.grey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "New Version is downloaded, ",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await Provider.of<UpdateProvider>(context, listen: false).installUpdate();
                            },
                            child: const Text("please click here to update."),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
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
      title: "Update",
      automaticallyImplyAppBarLeading: false,
    );
  }
}
