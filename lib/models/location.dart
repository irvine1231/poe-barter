import 'package:poe_trading_assistant/extensions/string_extension.dart';

class Location {
  final String stashTabName;
  final int left;
  final int top;

  bool get isAllSet => !stashTabName.isBlank && left > 0 && top > 0;

  Location({
    this.stashTabName = "",
    this.left = 0,
    this.top = 0,
  });

  @override
  String toString() {
    return "stashTabName: $stashTabName, left: $left, top: $top";
  }
}
