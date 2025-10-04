import 'package:drift/drift.dart';

import 'package:seleda_finance/features/transactions/domain/entities/attachment.dart' as domain;
import 'package:seleda_finance/features/transactions/domain/entities/transaction.dart' as domain;
import 'package:seleda_finance/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/date_range.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/money.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/transaction_type.dart';
import 'package:seleda_finance/features/transactions/infrastructure/data_sources/drift/database.dart';
import 'package:seleda_finance/features/transactions/infrastructure/data_sources/drift/transaction_dao.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._dao);

  final TransactionDao _dao;

  @override
  Future<void> add(domain.Transaction transaction) async {
  await _dao.insertTransaction(
      TransactionsCompanion(
        id: Value(transaction.id),
        dateEpochMs: Value(transaction.dateEpochMs),
        type: Value(transaction.type.name),
        amountCents: Value(transaction.amount.cents),
        category: Value(transaction.category),
        note: Value(transaction.note),
      ),
      transaction.attachments
          .map(
            (attachment) => AttachmentsCompanion(
              id: Value(attachment.id),
              transactionId: Value(attachment.transactionId),
              filePath: Value(attachment.filePath),
              mimeType: Value(attachment.mimeType),
            ),
          )
          .toList(),
    );
  }

  @override
  Future<void> delete(String id) => _dao.deleteTransactionById(id);

  @override
  Future<int> getBalanceCents() => _dao.computeBalance();

  @override
  Stream<List<domain.Transaction>> watchAll({DateRange? range, String? category}) {
    return _dao
        .watchTransactions(
          type: null,
          startEpochMs: range?.startEpochMs,
          endEpochMs: range?.endEpochMs,
          category: category,
        )
        .map(
          (rows) => rows
              .map(
                (row) => _mapToDomain(
                  row.transaction,
                  row.attachments,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<void> update(domain.Transaction transaction) async {
  await _dao.updateTransaction(
      TransactionsCompanion(
        id: Value(transaction.id),
        dateEpochMs: Value(transaction.dateEpochMs),
        type: Value(transaction.type.name),
        amountCents: Value(transaction.amount.cents),
        category: Value(transaction.category),
        note: Value(transaction.note),
      ),
      transaction.attachments
          .map(
            (attachment) => AttachmentsCompanion(
              id: Value(attachment.id),
              transactionId: Value(attachment.transactionId),
              filePath: Value(attachment.filePath),
              mimeType: Value(attachment.mimeType),
            ),
          )
          .toList(),
    );
  }

  domain.Transaction _mapToDomain(TransactionData data, List<AttachmentData> attachments) {
    return domain.Transaction(
      id: data.id,
      dateEpochMs: data.dateEpochMs,
      type: TransactionType.fromName(data.type),
      amount: Money.fromCents(data.amountCents),
      category: data.category,
      note: data.note,
      attachments: attachments
          .map(
            (attachment) => domain.Attachment(
              id: attachment.id,
              transactionId: attachment.transactionId,
              filePath: attachment.filePath,
              mimeType: attachment.mimeType,
            ),
          )
          .toList(),
    );
  }
}
