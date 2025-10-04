import 'package:seleda_finance/features/transactions/domain/entities/transaction.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/date_range.dart';

abstract class TransactionRepository {
  Future<void> add(Transaction transaction);
  Future<void> update(Transaction transaction);
  Future<void> delete(String id);
  Stream<List<Transaction>> watchAll({DateRange? range, String? category});
  Future<int> getBalanceCents();
}
