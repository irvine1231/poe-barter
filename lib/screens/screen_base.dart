import 'package:flutter/material.dart';
import 'package:poe_trading_assistant/providers/auto_update.dart';
import 'package:provider/provider.dart';

class ScreenBase extends StatelessWidget {
  const ScreenBase({
    required this.title,
    this.automaticallyImplyAppBarLeading = true,
    required this.body,
    this.floatingActionButton,
    Key? key,
  }) : super(key: key);

  final String title;
  final bool automaticallyImplyAppBarLeading;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: automaticallyImplyAppBarLeading,
        title: Text(title),
      ),
      body: Column(
        children: [
          if (Provider.of<UpdateProvider>(context).newVersionDownloaded)
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
                      "新版本已經下載完成，",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await Provider.of<UpdateProvider>(context, listen: false).installUpdate();
                      },
                      child: const Text("請點此安裝更新"),
                    ),
                  ],
                ),
              ),
            ),
          body,
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
