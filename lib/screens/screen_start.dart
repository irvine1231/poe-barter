import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:poe_barter/components/action_button.dart';
import 'package:poe_barter/components/label_value.dart';
import 'package:poe_barter/constants.dart';
import 'package:poe_barter/models/offer_state.dart';
import 'package:poe_barter/providers/offer.dart';
import 'package:poe_barter/providers/process.dart';
import 'package:poe_barter/screens/screen_base.dart';
import 'package:provider/provider.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

class ScreenStart extends StatefulWidget {
  const ScreenStart({Key? key}) : super(key: key);

  static const routeName = "/start";

  @override
  State<ScreenStart> createState() => _ScreenStartState();
}

class _ScreenStartState extends State<ScreenStart> with WindowListener {
  late final OfferProvider offerProvider = Provider.of<OfferProvider>(context);
  final AppWindow appWindow = AppWindow();

  @override
  void initState() {
    super.initState();

    initWindow();
  }

  Future<void> initWindow() async {
    await windowManager.setSize(Constants.screenStartSize);
    await windowManager.setPosition(Constants.screenStartPosition);

    await windowManager.setAlwaysOnTop(true);
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setIgnoreMouseEvents(true);
    await appWindow.hide();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBase(
      body: Expanded(
        child: Stack(
          children: [
            if (Provider.of<ProcessProvider>(context).poeProcessId == 0)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (Provider.of<ProcessProvider>(context).poeProcessId > 0)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (offerProvider.offers.isNotEmpty)
                    Flexible(
                      child: Center(
                        child: Container(
                          width: Constants.screenStartSize.width,
                          color: Colors.transparent,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: offerProvider.currentViewingOffer > 0
                                    ? () {
                                        setState(() {
                                          if (offerProvider.currentViewingOffer > 0) {
                                            offerProvider.currentViewingOffer -= 1;
                                          } else {
                                            return;
                                          }
                                        });
                                      }
                                    : null,
                                icon: Icon(
                                  Icons.chevron_left,
                                  color: offerProvider.currentViewingOffer > 0 ? Colors.white : Colors.grey.shade700,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      LabelValue(
                                        label: "Player",
                                        value: offerProvider
                                            .offers[offerProvider.currentViewingOffer].tradeEvent.playerName,
                                      ),
                                      LabelValue(
                                        label: "Item",
                                        value:
                                            offerProvider.offers[offerProvider.currentViewingOffer].tradeEvent.itemName,
                                        valueExtendWidth: true,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8.0,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      LabelValue(
                                        label: "StashTab",
                                        value: offerProvider.offers[offerProvider.currentViewingOffer].tradeEvent
                                                .location.stashTabName.isEmpty
                                            ? "Unknown"
                                            : offerProvider.offers[offerProvider.currentViewingOffer].tradeEvent
                                                .location.stashTabName,
                                      ),
                                      LabelValue(
                                        label: "Position",
                                        value: offerProvider.offers[offerProvider.currentViewingOffer].tradeEvent
                                                        .location.left ==
                                                    0 &&
                                                offerProvider.offers[offerProvider.currentViewingOffer].tradeEvent
                                                        .location.top ==
                                                    0
                                            ? "Unknown"
                                            : "left ${offerProvider.offers[offerProvider.currentViewingOffer].tradeEvent.location.left}, top ${offerProvider.offers[offerProvider.currentViewingOffer].tradeEvent.location.top}",
                                      ),
                                      LabelValue(
                                          label: "Price",
                                          value:
                                              "${offerProvider.offers[offerProvider.currentViewingOffer].tradeEvent.price.numberOfCurrency % 1 == 0 ? offerProvider.offers[offerProvider.currentViewingOffer].tradeEvent.price.numberOfCurrency.toInt() : offerProvider.offers[offerProvider.currentViewingOffer].tradeEvent.price.numberOfCurrency} ${EnumToString.convertToString(offerProvider.offers[offerProvider.currentViewingOffer].tradeEvent.price.currencyType)}"),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8.0,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 200,
                                        height: 25.6,
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 20),
                                            child: offerProvider.offers[offerProvider.currentViewingOffer].offerState ==
                                                    OfferState.offerReceived
                                                ? ActionButton(
                                                    onPressed: () {
                                                      offerProvider.sendInviteRequest(
                                                          offerProvider.offers[offerProvider.currentViewingOffer].id);
                                                    },
                                                    text: "Send Invite")
                                                : (offerProvider.offers[offerProvider.currentViewingOffer].offerState ==
                                                        OfferState.inviteSent
                                                    ? ActionButton(
                                                        onPressed: () {
                                                          offerProvider.sendTradeRequest(offerProvider
                                                              .offers[offerProvider.currentViewingOffer].id);
                                                        },
                                                        text: "Trade With",
                                                      )
                                                    : null)),
                                      ),
                                      SizedBox(
                                        width: 200,
                                        height: 25.6,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          child: ActionButton(
                                            onPressed: () {
                                              offerProvider.alreadySold(
                                                  offerProvider.offers[offerProvider.currentViewingOffer].id);
                                            },
                                            text: "Already Sold",
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 200,
                                        height: 25.6,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          child: ActionButton(
                                            onPressed: () {
                                              offerProvider
                                                  .dismiss(offerProvider.offers[offerProvider.currentViewingOffer].id);
                                            },
                                            text: "Dismiss",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: offerProvider.currentViewingOffer == (offerProvider.offers.length - 1)
                                    ? null
                                    : () {
                                        setState(() {
                                          if (offerProvider.currentViewingOffer == (offerProvider.offers.length - 1)) {
                                            return;
                                          } else {
                                            offerProvider.currentViewingOffer += 1;
                                          }
                                        });
                                      },
                                icon: Icon(
                                  Icons.chevron_right,
                                  color: offerProvider.currentViewingOffer == (offerProvider.offers.length - 1)
                                      ? Colors.grey.shade700
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
    // do something
  }
}
