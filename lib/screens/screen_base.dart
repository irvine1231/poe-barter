import 'package:flutter/material.dart';

class ScreenBase extends StatelessWidget {
  const ScreenBase({
    this.title,
    this.leading,
    this.backgroundColor = Colors.transparent,
    this.automaticallyImplyAppBarLeading = true,
    required this.body,
    this.floatingActionButton,
    Key? key,
  }) : super(key: key);

  final String? title;
  final Color? backgroundColor;
  final bool automaticallyImplyAppBarLeading;
  final Widget body;
  final Widget? leading;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              leading: leading,
              automaticallyImplyLeading: automaticallyImplyAppBarLeading,
              title: Text(title!),
            ),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // if (Provider.of<UpdateProvider>(context).newVersionDownloaded)
          //   Container(
          //     width: double.infinity,
          //     color: Colors.grey,
          //     child: Padding(
          //       padding: const EdgeInsets.symmetric(
          //         vertical: 4.0,
          //       ),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           const Text(
          //             "新版本已經下載完成，",
          //             style: TextStyle(
          //               color: Colors.white,
          //             ),
          //           ),
          //           TextButton(
          //             onPressed: () async {
          //               await Provider.of<UpdateProvider>(context, listen: false).installUpdate();
          //             },
          //             child: const Text("請點此安裝更新"),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          body,
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
