import 'dart:io';

import 'package:flutter/material.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:poe_barter/constants.dart';
import 'package:poe_barter/screens/screen_base.dart';
import 'package:poe_barter/screens/screen_start.dart';
import 'package:window_manager/window_manager.dart';

class ScreenError extends StatefulWidget {
  const ScreenError({
    super.key,
    required this.errorMsg,
  });

  final String errorMsg;
  static const routeName = "/error";

  @override
  State<ScreenError> createState() => _ScreenErrorState();
}

class _ScreenErrorState extends State<ScreenError> {
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
          ? Expanded(child: Container(alignment: Alignment.center, child: Text(widget.errorMsg)))
          : Container(),
      backgroundColor: Colors.white,
      trailing: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            exit(0);
          },
        ),
      ],
      title: "Error",
      automaticallyImplyAppBarLeading: false,
    );
  }
}
