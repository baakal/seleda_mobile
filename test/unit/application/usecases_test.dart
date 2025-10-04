import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:seleda_finance/core/result.dart';
import 'package:seleda_finance/features/transactions/application/dto/transaction_input_dto.dart';
import 'package:seleda_finance/features/transactions/application/usecases/add_transaction.dart';
import 'package:seleda_finance/features/transactions/application/usecases/compute_balance.dart';
import 'package:seleda_finance/features/transactions/application/usecases/delete_transaction.dart';
import 'package:seleda_finance/features/transactions/domain/entities/transaction.dart' as domain;
import 'package:seleda_finance/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/date_range.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/money.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/transaction_type.dart';

class _FakeTransactionRepository implements TransactionRepository {
  final _transactions = <domain.Transaction>[];
  final _controller = StreamController<List<domain.Transaction>>.broadcast();

  void _emit() => _controller.add(List.unmodifiable(_transactions));

  @override
  Future<void> add(domain.Transaction transaction) async {
    _transactions.add(transaction);
    _emit();
  }

  @override
  Future<void> delete(String id) async {
    _transactions.removeWhere((transaction) => transaction.id == id);
    _emit();
  }

  @override
  Future<int> getBalanceCents() async {
    var total = 0;
    for (final transaction in _transactions) {
      total += transaction.type == TransactionType.income
          ? transaction.amount.cents
          : -transaction.amount.cents;
    }
    return total;
  }

  @override
  Future<void> update(domain.Transaction transaction) async {}

  @override
  Stream<List<domain.Transaction>> watchAll({DateRange? range, String? category}) => _controller.stream;
}

void main() {
  group('Usecases', () {
    late _FakeTransactionRepository repository;

    setUp(() {
      repository = _FakeTransactionRepository();
    });

    test('add transaction usecase stores data', () async {
      final usecase = AddTransactionUseCase(repository);
      final dto = TransactionInputDto(
        type: TransactionType.income,
        amount: Money.fromCents(1000),
        dateEpochMs: DateTime(2023, 1, 1).millisecondsSinceEpoch,
      );

      final result = await usecase(dto);

      expect(result.isSuccess, isTrue);
      expect(repository.watchAll().first, completion(isNotEmpty));
    });

    test('delete transaction usecase removes data', () async {
      final add = AddTransactionUseCase(repository);
      final delete = DeleteTransactionUseCase(repository);
      final dto = TransactionInputDto(
        type: TransactionType.expense,
        amount: Money.fromCents(500),
        dateEpochMs: DateTime(2023, 1, 1).millisecondsSinceEpoch,
      );
      final addResult = await add(dto);
      expect(addResult.isSuccess, isTrue);
      final stored = await repository.watchAll().first;
      final id = stored.first.id;

      final deleteResult = await delete(id);
      expect(deleteResult.isSuccess, isTrue);
      expect(repository.watchAll().first, completion(isEmpty));
    });

    test('compute balance aggregates correctly', () async {
      final add = AddTransactionUseCase(repository);
      final compute = ComputeBalanceUseCase(repository);

      await add(TransactionInputDto(
        type: TransactionType.income,
        amount: Money.fromCents(2000),
        dateEpochMs: DateTime.now().millisecondsSinceEpoch,
      ));
      await add(TransactionInputDto(
        type: TransactionType.expense,
        amount: Money.fromCents(500),
        dateEpochMs: DateTime.now().millisecondsSinceEpoch,
      ));

      final result = await compute();
      result.fold(
        (money) => expect(money.cents, 1500),
        (failure) => fail('Expected success but got $failure'),
      );
    });
  });
}
