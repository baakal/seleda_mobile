import 'package:seleda_finance/core/error/failure.dart';
import 'package:seleda_finance/core/result.dart';
import 'package:seleda_finance/features/transactions/domain/repositories/transaction_repository.dart';

class DeleteTransactionUseCase {
  DeleteTransactionUseCase(this._repository);

  final TransactionRepository _repository;

  Future<Result<void, AppFailure>> call(String id) async {
    try {
      await _repository.delete(id);
      return const Success(null);
    } catch (error, stackTrace) {
      return Failure(AppFailure('Unable to delete transaction', cause: (error, stackTrace)));
    }
  }
}
