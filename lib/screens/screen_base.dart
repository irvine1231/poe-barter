import 'package:flutter/material.dart';

class ScreenBase extends StatelessWidget {
  const ScreenBase({
    this.title,
    this.leading,
    this.trailing,
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
  final List<Widget>? trailing;
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
              actions: trailing,
            ),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // if (Provider.of<UpdateProvider?>(context) != null &&
          //     Provider.of<UpdateProvider>(context).newVersionDownloaded)
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
          //             "New Version is downloaded, ",
          //             style: TextStyle(
          //               color: Colors.white,
          //             ),
          //           ),
          //           TextButton(
          //             onPressed: () async {
          //               await Provider.of<UpdateProvider>(context, listen: false).installUpdate();
          //             },
          //             child: const Text("please click here to update."),
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
