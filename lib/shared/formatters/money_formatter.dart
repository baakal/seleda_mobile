import 'package:intl/intl.dart';

import 'package:seleda_finance/features/transactions/domain/value_objects/money.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/transaction_type.dart';

final _currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: r'$');

String formatMoney(Money money, {TransactionType? type}) {
  final amount = money.cents / 100;
  final prefix = type == TransactionType.expense ? '-' : '';
  return '$prefix${_currencyFormat.format(amount.abs())}';
}
