class Event {
  static const String messageMarker = ": ";

  late final String message;
  late final String information;

  Event(String logLine) {
    message = parseMessage(logLine) ?? "";
    information = parseInformation(logLine) ?? "";
  }

  static String? parseInformation(String logLine) {
    int index = logLine.indexOf("]");
    return (index != -1) ? logLine.substring(index + 2) : null;
  }

  static String? parseMessage(String logLine) {
    int index = logLine.indexOf(messageMarker);

    return ((index != -1) ? logLine.substring(index + messageMarker.length) : null);
  }
}
