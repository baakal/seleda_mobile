import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seleda_finance/app/di.dart';
import 'package:seleda_finance/core/error/failure.dart';
import 'package:seleda_finance/core/result.dart';
import 'package:seleda_finance/features/transactions/domain/entities/transaction.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/transaction_type.dart';

class TransactionListState {
  const TransactionListState({
    required this.status,
    this.filter,
  });

  final AsyncValue<List<Transaction>> status;
  final TransactionType? filter;

  List<Transaction> get filteredTransactions {
    final data = status.value ?? <Transaction>[];
    if (filter == null) {
      return data;
    }
    return data.where((transaction) => transaction.type == filter).toList();
  }

  TransactionListState copyWith({
    AsyncValue<List<Transaction>>? status,
    TransactionType? filter,
    bool updateFilter = false,
  }) {
    return TransactionListState(
      status: status ?? this.status,
      filter: updateFilter ? filter : this.filter,
    );
  }
}

final transactionListControllerProvider = StateNotifierProvider<TransactionListController, TransactionListState>((ref) {
  return TransactionListController(ref)..initialize();
});

class TransactionListController extends StateNotifier<TransactionListState> {
  TransactionListController(this._ref)
      : super(const TransactionListState(status: AsyncValue.loading()));

  final Ref _ref;
  StreamSubscription<Result<List<Transaction>, AppFailure>>? _subscription;

  void initialize() {
    final useCase = _ref.read(watchTransactionsUseCaseProvider);
    _subscription = useCase().listen((event) {
      event.fold(
        (transactions) {
          state = state.copyWith(status: AsyncValue.data(transactions));
        },
        (error) {
          state = state.copyWith(status: AsyncValue.error(error, StackTrace.current));
        },
      );
    });
  }

  void setFilter(TransactionType? filter) {
    state = state.copyWith(filter: filter, updateFilter: true);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
