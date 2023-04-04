import 'package:poe_barter/models/currency_type.dart';

class Price {
  final double numberOfCurrency;
  final CurrencyType currencyType;

  bool get isAllSet => numberOfCurrency > 0 && currencyType != CurrencyType.unknown;

  Price({
    this.numberOfCurrency = 0,
    this.currencyType = CurrencyType.unknown,
  });

  @override
  String toString() {
    return "numberOfCurrency: $numberOfCurrency, currencyType: $currencyType";
  }
}
