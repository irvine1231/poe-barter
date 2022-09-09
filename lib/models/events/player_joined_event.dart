import 'package:flutter/foundation.dart';
import 'package:poe_trading_assistant/extensions/string_extension.dart';
import 'package:poe_trading_assistant/models/events/event.dart';

class PlayerJoinedEvent extends Event {
  static const List<String> joinedAreaMarkers = [
    "has joined the area",
    "進入了此區域",
  ];

  String playerName = "";

  PlayerJoinedEvent(String logLine) : super(logLine) {
    String playerJoinedMarkerString = "";
    int playerJoinedMarkerIndex = 0;
    for (String joinedAreaMarker in joinedAreaMarkers) {
      playerJoinedMarkerIndex = message.indexOf(joinedAreaMarker);

      // -1 means no marker found.
      if (playerJoinedMarkerIndex != -1) {
        playerJoinedMarkerString = joinedAreaMarker;
        break;
      }
    }

    playerName = message.before(playerJoinedMarkerString).trim();
    if (kDebugMode) {
      print("playerName: $playerName");
    }
  }

  static PlayerJoinedEvent? tryParse(String logLine) {
    String? message = Event.parseMessage(logLine);

    return (message != null && joinedAreaMarkers.any((joinedAreaMarker) => message.contains(joinedAreaMarker)))
        ? PlayerJoinedEvent(logLine)
        : null;
  }
}
