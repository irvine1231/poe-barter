extension StringExtension on String {
  bool get isBlank => trim().isEmpty;

  String after(String pattern) {
    if (isBlank) {
      return this;
    }

    if (!contains(pattern)) {
      return "";
    }

    int indexOfLastPatternWord = indexOf(pattern) + pattern.length;

    return substring(indexOfLastPatternWord, length);
  }

  String before(String pattern) {
    if (isBlank) {
      return this;
    }

    if (!contains(pattern)) {
      return "";
    }

    int indexOfFirstPatternWord = indexOf(pattern);

    return substring(
      0,
      indexOfFirstPatternWord,
    );
  }
}
