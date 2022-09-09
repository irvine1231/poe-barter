import 'package:flutter/foundation.dart';
import 'package:poe_trading_assistant/extensions/string_extension.dart';
import 'package:poe_trading_assistant/models/events/player_joined_event.dart';
import 'package:poe_trading_assistant/models/events/trade_accepted_event.dart';
import 'package:poe_trading_assistant/models/events/trade_event.dart';
import 'package:poe_trading_assistant/models/offer.dart';
import 'package:poe_trading_assistant/models/offer_state.dart';
import 'package:poe_trading_assistant/providers/process.dart';
import 'package:poe_trading_assistant/providers/setting.dart';

class OfferProvider extends ChangeNotifier {
  late ProcessProvider processProvider;
  late SettingProvider settingProvider;

  List<Offer> offers = [];

  Offer? _currentTradingOffer;

  void addOffer(TradeEvent tradeEvent) {
    offers.add(
      Offer(tradeEvent: tradeEvent),
    );

    if (kDebugMode) {
      print(offers);
    }

    notifyListeners();
  }

  void _removeOffer(String offerId) {
    offers.removeAt(offers.indexWhere((offer) => offer.id == offerId));

    notifyListeners();
  }

  int findOfferById(String offerId) {
    return offers.indexWhere((offer) => offer.id == offerId);
  }

  int findOfferByPlayerName(String playerName) {
    return offers.indexWhere((offer) => offer.tradeEvent.playerName == playerName);
  }

  void setOfferState(String offerId, OfferState newOfferState) {
    int offerIndex = findOfferById(offerId);
    if (offerIndex == -1) return;

    offers[offerIndex].setOfferState(newOfferState);

    notifyListeners();
  }

  void handleTrade(TradeEvent tradeEvent) {
    if (!tradeEvent.isAllSet) return;

    // Skip if the incoming offer exists in offers.
    if (offers.any((offer) => offer.tradeEvent.toString() == tradeEvent.toString())) return;

    addOffer(tradeEvent);

    notifyListeners();
  }

  void sendInviteRequest(String offerId) {
    int offerIndex = findOfferById(offerId);
    if (offerIndex == -1) return;

    processProvider.sendInviteCommand(offers[offerIndex].tradeEvent.playerName);
    setOfferState(offers[offerIndex].id, OfferState.inviteSent);

    notifyListeners();
  }

  void handlePlayerJoined(PlayerJoinedEvent playerJoinedEvent) {
    if (playerJoinedEvent.playerName.isBlank) return;

    int offerIndex = findOfferByPlayerName(playerJoinedEvent.playerName);
    if (offerIndex == -1) return;

    setOfferState(offers[offerIndex].id, OfferState.playerJoined);

    notifyListeners();
  }

  void sendTradeRequest(String offerId) {
    int offerIndex = findOfferById(offerId);
    _currentTradingOffer = offers[offerIndex];

    processProvider.sendTradeWithCommand(_currentTradingOffer!.tradeEvent.playerName);
    setOfferState(offers[offerIndex].id, OfferState.tradeSent);

    notifyListeners();
  }

  void handleTradeAccepted(TradeAcceptedEvent tradeAcceptedEvent) {
    if (_currentTradingOffer == null) return;

    processProvider.sendWhisperCommand(_currentTradingOffer!.tradeEvent.playerName, settingProvider.tradeSuccessMsg);
    processProvider.sendKickCommand(settingProvider.selfCharacterName);

    _currentTradingOffer = null;
    _removeOffer(_currentTradingOffer!.id);

    notifyListeners();
  }

  void alreadySold(String offerId) {
    int offerIndex = findOfferById(offerId);
    if (offerIndex == -1) return;

    processProvider.sendWhisperCommand(
      offers[offerIndex].tradeEvent.playerName,
      settingProvider.alreadySoldMsg.replaceAll("@itemName", offers[offerIndex].tradeEvent.itemName),
    );

    _removeOffer(offerId);

    notifyListeners();
  }

  void dismiss(String offerId) {
    int offerIndex = findOfferById(offerId);
    if (offerIndex == -1) return;

    _removeOffer(offerId);

    notifyListeners();
  }
}
