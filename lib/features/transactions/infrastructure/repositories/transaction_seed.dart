import 'package:drift/drift.dart';

import 'package:seleda_finance/features/transactions/infrastructure/data_sources/drift/database.dart';

Future<void> transactionSeed(AppDatabase db) async {
  final count = await db.select(db.transactions).get();
  if (count.isNotEmpty) {
    return;
  }
  await db.batch((batch) {
    batch.insertAll(db.transactions, [
      TransactionsCompanion.insert(
        id: 'seed-income-1',
        dateEpochMs: DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch,
        type: 'income',
        amountCents: 500000,
        category: const Value('Salary'),
        note: const Value('Welcome bonus'),
      ),
      TransactionsCompanion.insert(
        id: 'seed-expense-1',
        dateEpochMs: DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        type: 'expense',
        amountCents: 12000,
        category: const Value('Coffee'),
        note: const Value('Morning latte'),
      ),
      TransactionsCompanion.insert(
        id: 'seed-expense-2',
        dateEpochMs: DateTime.now().millisecondsSinceEpoch,
        type: 'expense',
        amountCents: 45000,
        category: const Value('Groceries'),
        note: const Value('Weekly essentials'),
      ),
    ]);
  });
}
