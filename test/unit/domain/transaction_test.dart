import 'package:flutter_test/flutter_test.dart';

import 'package:seleda_finance/features/transactions/domain/entities/transaction.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/money.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/transaction_type.dart';

void main() {
  test('transaction rejects negative amounts', () {
    expect(
      () => Transaction(
        id: 't1',
        dateEpochMs: DateTime.now().millisecondsSinceEpoch,
        type: TransactionType.expense,
        amount: Money.fromCents(-100),
      ),
      throwsA(isA<AssertionError>()),
    );
  });
}
