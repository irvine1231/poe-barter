import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:poe_trading_assistant/components/label_value.dart';
import 'package:poe_trading_assistant/constants.dart';
import 'package:poe_trading_assistant/models/offer.dart';
import 'package:poe_trading_assistant/models/offer_state.dart';
import 'package:poe_trading_assistant/providers/offer.dart';
import 'package:poe_trading_assistant/providers/process.dart';
import 'package:poe_trading_assistant/screens/screen_base.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class ScreenStart extends StatefulWidget {
  const ScreenStart({Key? key}) : super(key: key);

  static const routeName = "/start";

  @override
  State<ScreenStart> createState() => _ScreenStartState();
}

class _ScreenStartState extends State<ScreenStart> with WindowListener {
  late final OfferProvider offerProvider = Provider.of<OfferProvider>(context);

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
                  Flexible(
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        Offer offer = offerProvider.offers[index];

                        return Center(
                          child: Container(
                            width: 600,
                            color: Colors.transparent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    LabelValue(
                                      label: "Player",
                                      value: offer.tradeEvent.playerName,
                                    ),
                                    LabelValue(
                                      label: "Item",
                                      value: offer.tradeEvent.itemName,
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
                                      value: offer.tradeEvent.location.stashTabName,
                                    ),
                                    LabelValue(
                                      label: "Position",
                                      value:
                                          "left ${offer.tradeEvent.location.left}, top ${offer.tradeEvent.location.top}",
                                    ),
                                    LabelValue(
                                        label: "Price",
                                        value:
                                            "${offer.tradeEvent.price.numberOfCurrency % 1 == 0 ? offer.tradeEvent.price.numberOfCurrency.toInt() : offer.tradeEvent.price.numberOfCurrency} ${EnumToString.convertToString(offer.tradeEvent.price.currencyType)}"),
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
                                      label: "",
                                      valueWidget: offer.offerState == OfferState.offerReceived
                                          ? ElevatedButton(
                                              onPressed: () {
                                                offerProvider.sendInviteRequest(offer.id);
                                              },
                                              child: const Text("Send Invite"),
                                            )
                                          : (offer.offerState == OfferState.inviteSent
                                              ? const ElevatedButton(
                                                  onPressed: null,
                                                  child: Text("Invite Sent"),
                                                )
                                              : (offer.offerState == OfferState.playerJoined
                                                  ? ElevatedButton(
                                                      onPressed: () {
                                                        offerProvider.sendTradeRequest(offer.id);
                                                      },
                                                      child: const Text("Trade With"),
                                                    )
                                                  : null)),
                                    ),
                                    LabelValue(
                                      label: "",
                                      valueWidget: ElevatedButton(
                                        onPressed: () {
                                          offerProvider.alreadySold(offer.id);
                                        },
                                        child: const Text("Already Sold"),
                                      ),
                                    ),
                                    LabelValue(
                                      label: "",
                                      valueWidget: ElevatedButton(
                                        onPressed: () {
                                          offerProvider.dismiss(offer.id);
                                        },
                                        child: const Text("Dismiss"),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      // separatorBuilder: (BuildContext context, int index) => const Divider(),
                      itemCount: offerProvider.offers.length,
                      shrinkWrap: true,
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
