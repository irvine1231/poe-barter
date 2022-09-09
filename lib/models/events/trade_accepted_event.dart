import 'package:poe_trading_assistant/models/events/event.dart';

class TradeAcceptedEvent extends Event {
  static final List<String> tradeAcceptedMarkers = [
    "Trade accepted",
    "Handel angenommen",
    "${String.fromCharCode(0x00c9)}change accept${String.fromCharCode(0x00e9)}",
    "Negocia${String.fromCharCode(0x00e7)}${String.fromCharCode(0x00e3)}o aceita",
    "Сделка совершена",
    "ยอมรับการแลกเปลี่ยนแล้ว",
    "Intercambio aceptado",
    "거래를 수락했습니다",
    "完成交易",
  ];

  TradeAcceptedEvent(String logLine) : super(logLine);

  static TradeAcceptedEvent? tryParse(String logLine) {
    String? message = Event.parseMessage(logLine);

    return (message != null && tradeAcceptedMarkers.any((tradeAcceptedMarker) => message.contains(tradeAcceptedMarker)))
        ? TradeAcceptedEvent(logLine)
        : null;
  }
}
