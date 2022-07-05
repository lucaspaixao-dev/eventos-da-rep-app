import 'package:money2/money2.dart';

String centsToReal(int value) {
  Currency currency = Currency.create('BRL', 2, symbol: "R\$ ");
  Money price = Money.fromIntWithCurrency(value, currency);

  return price.toString();
}
