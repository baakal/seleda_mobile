import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seleda_finance/features/transactions/infrastructure/data_sources/drift/database.dart';
import 'package:seleda_finance/features/transactions/infrastructure/data_sources/drift/transaction_dao.dart';

void main() {
  late AppDatabase db;
  late TransactionDao dao;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = TransactionDao(db);
    await db.customStatement('PRAGMA foreign_keys = ON');
  });

  tearDown(() async {
    await db.close();
  });

  test('insert and watch transactions', () async {
    await dao.insertTransaction(
      TransactionsCompanion(
        id: const Value('1'),
        dateEpochMs: Value(DateTime(2023, 1, 1).millisecondsSinceEpoch),
        type: const Value('income'),
        amountCents: const Value(1000),
        category: const Value('Salary'),
        note: const Value('January'),
      ),
      [
        AttachmentsCompanion(
          id: const Value('a1'),
          transactionId: const Value('1'),
          filePath: const Value('/path/receipt.jpg'),
          mimeType: const Value('image/jpeg'),
        ),
      ],
    );

    final stream = dao.watchTransactions();
    final result = await stream.first;
    expect(result, isNotEmpty);
    expect(result.first.attachments.length, 1);
  });

  test('delete cascades attachments', () async {
    await dao.insertTransaction(
      TransactionsCompanion(
        id: const Value('1'),
        dateEpochMs: Value(DateTime(2023, 1, 1).millisecondsSinceEpoch),
        type: const Value('expense'),
        amountCents: const Value(500),
        category: const Value('Food'),
        note: const Value('Lunch'),
      ),
      [
        AttachmentsCompanion(
          id: const Value('a1'),
          transactionId: const Value('1'),
          filePath: const Value('/path/receipt.jpg'),
          mimeType: const Value('image/jpeg'),
        ),
      ],
    );

    await dao.deleteTransactionById('1');

    final attachmentsCount = await db.select(db.attachments).get();
    expect(attachmentsCount, isEmpty);
  });
}
