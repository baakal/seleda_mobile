import 'package:drift/drift.dart';

import 'package:seleda_finance/features/transactions/infrastructure/data_sources/drift/database.dart';

part 'transaction_dao.g.dart';

class TransactionWithAttachments {
  TransactionWithAttachments({
    required this.transaction,
    required this.attachments,
  });

  final TransactionData transaction;
  final List<AttachmentData> attachments;
}

@DriftAccessor(tables: [Transactions, Attachments])
class TransactionDao extends DatabaseAccessor<AppDatabase> with _$TransactionDaoMixin {
  TransactionDao(AppDatabase db) : super(db);

  Future<void> insertTransaction(TransactionsCompanion data, List<AttachmentsCompanion> attachments) async {
    await transaction(() async {
      await into(transactions).insertOnConflictUpdate(data);
      if (attachments.isNotEmpty) {
        await batch((batch) {
          batch.insertAllOnConflictUpdate(this.attachments, attachments);
        });
      }
    });
  }

  Future<void> updateTransaction(TransactionsCompanion data, List<AttachmentsCompanion> attachments) async {
    await transaction(() async {
      await into(transactions).insertOnConflictUpdate(data);
      await (delete(attachmentsTable)..where((tbl) => tbl.transactionId.equals(data.id.value))).go();
      if (attachments.isNotEmpty) {
        await batch((batch) {
          batch.insertAllOnConflictUpdate(this.attachments, attachments);
        });
      }
    });
  }

  Future<void> deleteTransactionById(String id) async {
    await transaction(() async {
      await (delete(attachmentsTable)..where((tbl) => tbl.transactionId.equals(id))).go();
      await (delete(transactions)..where((tbl) => tbl.id.equals(id))).go();
    });
  }

  Stream<List<TransactionWithAttachments>> watchTransactions({
    String? type,
    int? startEpochMs,
    int? endEpochMs,
    String? category,
  }) {
    final query = select(transactions)
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.dateEpochMs, mode: OrderingMode.desc),
      ]);
    if (type != null) {
      query.where((tbl) => tbl.type.equals(type));
    }
    if (startEpochMs != null) {
      query.where((tbl) => tbl.dateEpochMs.isBiggerOrEqualValue(startEpochMs));
    }
    if (endEpochMs != null) {
      query.where((tbl) => tbl.dateEpochMs.isSmallerOrEqualValue(endEpochMs));
    }
    if (category != null) {
      query.where((tbl) => tbl.category.equals(category));
    }
    return query.watch().asyncMap((rows) async {
      final results = <TransactionWithAttachments>[];
      for (final row in rows) {
        final attachmentsData = await (select(attachments)..where((tbl) => tbl.transactionId.equals(row.id))).get();
        results.add(TransactionWithAttachments(transaction: row, attachments: attachmentsData));
      }
      return results;
    });
  }

  Future<int> computeBalance() async {
    final income = await (select(transactions)
          ..where((tbl) => tbl.type.equals('income')))
        .map((row) => row.amountCents)
        .get();
    final expense = await (select(transactions)
          ..where((tbl) => tbl.type.equals('expense')))
        .map((row) => row.amountCents)
        .get();
    final incomeSum = income.fold<int>(0, (acc, value) => acc + value);
    final expenseSum = expense.fold<int>(0, (acc, value) => acc + value);
    return incomeSum - expenseSum;
  }

  Future<TransactionWithAttachments?> getTransactionById(String id) async {
    final transactionData = await (select(transactions)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (transactionData == null) {
      return null;
    }
    final attachmentsData = await (select(attachments)..where((tbl) => tbl.transactionId.equals(id))).get();
    return TransactionWithAttachments(transaction: transactionData, attachments: attachmentsData);
  }

  Attachments get attachmentsTable => attachments;
}
