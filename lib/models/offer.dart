import 'package:flutter/foundation.dart';
import 'package:poe_barter/models/events/trade_event.dart';
import 'package:poe_barter/models/offer_state.dart';

class Offer {
  final String id = UniqueKey().toString();
  final TradeEvent tradeEvent;
  OfferState offerState = OfferState.offerReceived;

  Offer({
    required this.tradeEvent,
  });

  void setOfferState(OfferState newOfferState) {
    bool isValidState = false;

    switch (newOfferState) {
      case OfferState.offerReceived:
        isValidState = false;
        break;

      case OfferState.inviteSent:
        if (offerState == OfferState.offerReceived) {
          isValidState = true;
        }
        break;

      case OfferState.playerJoined:
        if (offerState == OfferState.inviteSent) {
          isValidState = true;
        }
        break;

      case OfferState.tradeSent:
        if (offerState == OfferState.playerJoined) {
          isValidState = true;
        }
        break;

      case OfferState.finished:
        if (offerState == OfferState.tradeSent) {
          isValidState = true;
        }
        break;

      case OfferState.canceled:
        isValidState = true;
        break;
    }

    if (isValidState) {
      offerState = newOfferState;
    }
  }

  @override
  String toString() {
    return "Id: $id, offerState: $offerState, tradeEvent: $tradeEvent";
  }
}
