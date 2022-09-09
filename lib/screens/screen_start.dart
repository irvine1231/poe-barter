import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:poe_trading_assistant/models/offer.dart';
import 'package:poe_trading_assistant/models/offer_state.dart';
import 'package:poe_trading_assistant/providers/offer.dart';
import 'package:poe_trading_assistant/providers/process.dart';
import 'package:poe_trading_assistant/screens/screen_base.dart';
import 'package:provider/provider.dart';

class ScreenStart extends StatefulWidget {
  const ScreenStart({Key? key}) : super(key: key);

  static const routeName = "/start";

  @override
  State<ScreenStart> createState() => _ScreenStartState();
}

class _ScreenStartState extends State<ScreenStart> {
  late final OfferProvider offerProvider = Provider.of<OfferProvider>(context);

  @override
  Widget build(BuildContext context) {
    return ScreenBase(
      body: Expanded(
        child: Stack(
          children: [
            Opacity(
              opacity: 0.4,
              child: Container(
                color: Colors.grey,
              ),
            ),
            if (Provider.of<ProcessProvider>(context).poeProcessId == 0)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (Provider.of<ProcessProvider>(context).poeProcessId > 0)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Provider.of<ProcessProvider>(context, listen: false).sendHideoutCommand();
                          },
                          child: const Text("Send Hideout Command or Press F5 in game"),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 32.0,
                    ),
                    Flexible(
                      child: ListView.separated(
                        itemBuilder: (BuildContext context, int index) {
                          Offer offer = offerProvider.offers[index];

                          return Center(
                            child: Container(
                              width: 1000,
                              color: Colors.grey.shade400,
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Player: ${offer.tradeEvent.playerName}"),
                                      const SizedBox(
                                        height: 16.0,
                                      ),
                                      Text("Item: ${offer.tradeEvent.itemName}"),
                                      const SizedBox(
                                        height: 16.0,
                                      ),
                                      Text("StashTab: ${offer.tradeEvent.location.stashTabName}"),
                                      const SizedBox(
                                        height: 16.0,
                                      ),
                                      Text(
                                          "Position: left ${offer.tradeEvent.location.left}, top ${offer.tradeEvent.location.top}"),
                                      const SizedBox(
                                        height: 16.0,
                                      ),
                                      Text(
                                        "Price: ${offer.tradeEvent.price.numberOfCurrency % 1 == 0 ? offer.tradeEvent.price.numberOfCurrency.toInt() : offer.tradeEvent.price.numberOfCurrency} ${EnumToString.convertToString(offer.tradeEvent.price.currencyType)}",
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 16.0,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      if (offer.offerState == OfferState.offerReceived)
                                        ElevatedButton(
                                          onPressed: () {
                                            offerProvider.sendInviteRequest(offer.id);
                                          },
                                          child: const Text("Send Invite"),
                                        ),
                                      if (offer.offerState == OfferState.inviteSent)
                                        const ElevatedButton(
                                          onPressed: null,
                                          child: Text("Invite Sent"),
                                        ),
                                      if (offer.offerState == OfferState.playerJoined)
                                        ElevatedButton(
                                          onPressed: () {
                                            offerProvider.sendTradeRequest(offer.id);
                                          },
                                          child: const Text("Trade With"),
                                        ),
                                      const SizedBox(
                                        width: 16.0,
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          offerProvider.alreadySold(offer.id);
                                        },
                                        child: const Text("Already Sold"),
                                      ),
                                      const SizedBox(
                                        width: 16.0,
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          offerProvider.dismiss(offer.id);
                                        },
                                        child: const Text("Dismiss"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) => const Divider(),
                        itemCount: offerProvider.offers.length,
                        shrinkWrap: true,
                      ),
                    )
                  ],
                ),
              )
          ],
        ),
      ),
      title: 'Offers',
      automaticallyImplyAppBarLeading: false,
    );
  }
}
