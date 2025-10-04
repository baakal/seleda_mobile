import 'dart:async';

import 'package:seleda_finance/core/error/failure.dart';
import 'package:seleda_finance/core/result.dart';
import 'package:seleda_finance/features/transactions/domain/entities/transaction.dart';
import 'package:seleda_finance/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/date_range.dart';

class WatchTransactionsUseCase {
  WatchTransactionsUseCase(this._repository);

  final TransactionRepository _repository;

  Stream<Result<List<Transaction>, AppFailure>> call({
    DateRange? range,
    String? category,
  }) {
    return _repository.watchAll(range: range, category: category).transform(
      StreamTransformer.fromHandlers(handleError: (error, stackTrace, sink) {
        sink.add(Failure(AppFailure('Unable to watch transactions', cause: (error, stackTrace))));
      }, handleData: (transactions, sink) {
        sink.add(Success<List<Transaction>, AppFailure>(transactions));
      }),
    );
  }
}
