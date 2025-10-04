import 'package:seleda_finance/core/error/failure.dart';
import 'package:seleda_finance/core/result.dart';
import 'package:seleda_finance/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/money.dart';

class ComputeBalanceUseCase {
  ComputeBalanceUseCase(this._repository);

  final TransactionRepository _repository;

  Future<Result<Money, AppFailure>> call() async {
    try {
      final cents = await _repository.getBalanceCents();
      return Success(Money.fromCents(cents));
    } catch (error, stackTrace) {
      return Failure(AppFailure('Unable to compute balance', cause: (error, stackTrace)));
    }
  }
}
