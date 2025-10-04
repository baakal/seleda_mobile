import 'package:uuid/uuid.dart';

import 'package:seleda_finance/core/error/failure.dart';
import 'package:seleda_finance/core/result.dart';
import 'package:seleda_finance/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:seleda_finance/features/transactions/application/dto/transaction_input_dto.dart';

class UpdateTransactionUseCase {
  UpdateTransactionUseCase(this._repository, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final TransactionRepository _repository;
  final Uuid _uuid;

  Future<Result<void, AppFailure>> call(TransactionInputDto input) async {
    if (input.id == null) {
      return Failure(AppFailure('Transaction id is required for updates'));
    }
    try {
      final transaction = input.toDomain(idGenerator: _uuid.v4);
      await _repository.update(transaction);
      return const Success(null);
    } catch (error, stackTrace) {
      return Failure(AppFailure('Unable to update transaction', cause: (error, stackTrace)));
    }
  }
}
