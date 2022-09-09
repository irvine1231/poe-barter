import 'package:poe_trading_assistant/extensions/string_extension.dart';
import 'package:poe_trading_assistant/models/events/event.dart';

class WhisperEvent extends Event {
  static const String endOfGuildNameMarker = ">";

  static final List<String> toMarkers = [
    "@To",
    "@An",
    "@${String.fromCharCode(0x00c0)}",
    "@Para",
    "@От",
    "@ถึง",
    "@Para",
    "@발신",
    "@向",
  ];

  static final List<String> fromMarkers = [
    "@From",
    "@Von",
    "@De",
    "@De",
    "@Кому",
    "@จาก",
    "@De",
    "@수신",
    "@來自",
  ];

  late final String playerName;

  WhisperEvent(String logLine) : super(logLine) {
    playerName = information.before(Event.messageMarker).after(endOfGuildNameMarker).trim();
  }

  static WhisperEvent? tryParse(String logLine) {
    if (!isIncoming(logLine)) return null;

    return WhisperEvent(logLine);
  }

  static bool isIncoming(String logLine) {
    String? information = Event.parseInformation(logLine);

    return information != null && fromMarkers.any((fromMarker) => information.startsWith(fromMarker));
  }

// static bool _isOutGoing(String logLine`) {}
}
