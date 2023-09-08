import 'package:flutter/foundation.dart';
import 'package:poe_barter/extensions/string_extension.dart';
import 'package:poe_barter/models/events/player_joined_event.dart';
import 'package:poe_barter/models/events/trade_accepted_event.dart';
import 'package:poe_barter/models/events/trade_event.dart';
import 'package:poe_barter/models/offer.dart';
import 'package:poe_barter/models/offer_state.dart';
import 'package:poe_barter/providers/process.dart';
import 'package:poe_barter/providers/setting.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

class OfferProvider extends ChangeNotifier {
  final AppWindow appWindow = AppWindow();
  late ProcessProvider processProvider;
  late SettingProvider settingProvider;

  List<Offer> offers = [];

  int currentViewingOffer = 0;
  Offer? _currentTradingOffer;

  void addOffer(TradeEvent tradeEvent) {
    offers.add(
      Offer(tradeEvent: tradeEvent),
    );

    if (kDebugMode) {
      print(offers);
    }

    if (offers.isNotEmpty) {
      appWindow.show();
      windowManager.setIgnoreMouseEvents(false);
    }

    print(currentViewingOffer);
    notifyListeners();
  }

  void _removeOffer(String offerId) {
    int removeIndex = offers.indexWhere((offer) => offer.id == offerId);
    if (removeIndex == (offers.length - 1) && removeIndex != 0) {
      currentViewingOffer = removeIndex - 1;
    }

    offers.removeAt(removeIndex);

    if (offers.isEmpty) {
      windowManager.setIgnoreMouseEvents(true);
      appWindow.hide();
    }

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
    processProvider.sendKickCommand(_currentTradingOffer!.tradeEvent.playerName);

    _removeOffer(_currentTradingOffer!.id);
    _currentTradingOffer = null;

    notifyListeners();
  }

  void alreadySold(String offerId) {
    int offerIndex = findOfferById(offerId);
    if (offerIndex == -1) return;

    processProvider.sendWhisperCommand(
      offers[offerIndex].tradeEvent.playerName,
      settingProvider.alreadySoldMsg.replaceAll(
          "@itemName", "The item" /*offers[offerIndex].tradeEvent.itemName*/), // 中文化後物品也會變中文，傳出去對方會看不懂，先改成 Item。
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
