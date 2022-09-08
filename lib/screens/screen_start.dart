import 'package:flutter/material.dart';
import 'package:poe_trading_assistant/providers/test.dart';
import 'package:provider/provider.dart';

class ScreenStart extends StatefulWidget {
  const ScreenStart({Key? key}) : super(key: key);

  static const routeName = "/start";

  @override
  State<ScreenStart> createState() => _ScreenStartState();
}

class _ScreenStartState extends State<ScreenStart> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.4,
          child: Container(
            color: Colors.grey,
          ),
        ),
        if (Provider.of<TestProvider>(context).poeProcessId == 0)
          const Center(
            child: CircularProgressIndicator(),
          ),
        if (Provider.of<TestProvider>(context).poeProcessId > 0)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Provider.of<TestProvider>(context, listen: false).sendHideoutCommand();
                  },
                  child: const Text("Send Hideout Command"),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<TestProvider>(context, listen: false).sendInviteCommand("Kalandra_cow");
                  },
                  child: const Text("Send Invite Command"),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<TestProvider>(context, listen: false).sendKickCommand("KalandraPig");
                  },
                  child: const Text("Send Kick Command"),
                ),
              ],
            ),
          )
      ],
    );
  }
}
