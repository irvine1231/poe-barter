import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:poe_barter/extensions/string_extension.dart';
import 'package:poe_barter/models/currency_type.dart';
import 'package:poe_barter/models/events/event.dart';
import 'package:poe_barter/models/events/whisper_event.dart';
import 'package:poe_barter/models/location.dart';
import 'package:poe_barter/models/price.dart';

class TradeEvent extends WhisperEvent {
  static const List<String> greetingMarkers = [
    "Hi, I would like to buy your",
    "Hi, I'd like to buy your",
    "wtb",
  ];

  static const List<String> priceMarkers = [
    "listed for",
    "for my",
    " for",
  ];

  static const String leagueMarker = " in ";

  static const String locationMarker = "(";
  static const String locationMarkerEnd = ")";
  static const String positionMarker = "position: ";

  String leagueName = "";
  String itemName = "";
  late Location location;
  late Price price;

  bool get isAllSet => !leagueName.isBlank && !itemName.isBlank && location.isAllSet && price.isAllSet;

  TradeEvent(String logLine) : super(logLine) {
    if (kDebugMode) {
      print(message);
      print(information);
      print(playerName);
    }

    String priceMarkerString = "";
    int priceMarkerIndex = 0;
    for (String priceMarker in priceMarkers) {
      priceMarkerIndex = message.indexOf(priceMarker);

      // -1 means no marker found.
      if (priceMarkerIndex != -1) {
        priceMarkerString = priceMarker;
        break;
      }
    }

    int leagueMarkerIndex = message.indexOf(leagueMarker);
    if (leagueMarkerIndex != -1) {
      leagueName = message.after(leagueMarker).split(" (").first;
      leagueName = leagueName.trim().replaceAll(".", "");
    }

    priceMarkerIndex = (priceMarkerIndex == -1) ? (leagueMarkerIndex + 1) : priceMarkerIndex;
    String itemNameString = message.substring(0, priceMarkerIndex);

    String greetingMarkerString = "";
    for (String greetingMarker in greetingMarkers) {
      if (message.contains(greetingMarker)) {
        greetingMarkerString = greetingMarker;
      }
    }

    itemName = itemNameString.substring(greetingMarkerString.length + 1);

    String locationString = message.substring(priceMarkerIndex);
    location = parseLocation(locationString);

    price = parsePrice(priceMarkerIndex, priceMarkerString);
    if (kDebugMode) {
      print("leagueName: $leagueName");
      print("itemName: $itemName");
      print("location: $location");
      print("price: $price");
    }
  }

  static TradeEvent? tryParse(String logLine) {
    if (WhisperEvent.isIncoming(logLine)) {
      String message = Event.parseMessage(logLine) as String;
      if (greetingMarkers.any((greetingMarker) => message.startsWith(greetingMarker))) {
        return TradeEvent(logLine);
      }
    }

    return null;
  }

  Location parseLocation(String locationString) {
    Location location;

    int locationMarkerEndIndex = locationString.indexOf(locationMarkerEnd);
    if ((!locationString.contains(locationMarker)) || (locationMarkerEndIndex == -1)) {
      location = Location();
    } else {
      // Get stash tab name
      String stashTabName = "";
      String tmpStashTabName = locationString.before("\";");
      if (tmpStashTabName.isNotEmpty) {
        stashTabName = tmpStashTabName.substring(tmpStashTabName.indexOf("\"") + 1);
      }

      // Get position
      String positionString = locationString.after(";");
      positionString = positionString.before(locationMarkerEnd);
      if (positionString.contains(positionMarker)) {
        positionString = positionString.after(positionMarker);
      }

      List<String> positionArray = positionString.split(", ");
      int left = int.parse(positionArray[0].after("left "));
      int top = int.parse(positionArray[1].after("top "));

      location = Location(
        stashTabName: stashTabName,
        left: left,
        top: top,
      );
    }

    return location;
  }

  Price parsePrice(int priceMarkerIndex, String priceMarkerString) {
    Price price;

    if (priceMarkerIndex == -1) {
      price = Price();
    } else {
      String priceString = message.substring(priceMarkerIndex + priceMarkerString.length + 1);

      if (priceString.contains(leagueMarker)) {
        int leagueMarkerIndex = priceString.indexOf(leagueMarker);
        priceString = priceString.substring(0, leagueMarkerIndex);
      }

      List<String> priceArray = priceString.split(" ");

      double numberOfCurrency = double.parse(priceArray[0]);
      CurrencyType currencyType = EnumToString.fromString(CurrencyType.values, priceArray[1]) ?? CurrencyType.unknown;

      price = Price(
        numberOfCurrency: numberOfCurrency,
        currencyType: currencyType,
      );
    }

    return price;
  }

  @override
  String toString() {
    return "leagueName: $leagueName, itemName: $itemName, location: $location, price: $price";
  }
}
