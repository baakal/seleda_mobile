import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seleda_finance/app/di.dart';
import 'package:seleda_finance/core/result.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/money.dart';

final balanceProvider = StreamProvider<Money>((ref) {
  final watchUseCase = ref.watch(watchTransactionsUseCaseProvider);
  final computeUseCase = ref.watch(computeBalanceUseCaseProvider);
  final controller = StreamController<Money>();

  Future<void> refreshBalance() async {
    final result = await computeUseCase();
    result.fold(
      controller.add,
      (error) => controller.addError(error, StackTrace.current),
    );
  }

  final subscription = watchUseCase().listen((event) {
    event.fold(
      (_) => refreshBalance(),
      (error) => controller.addError(error, StackTrace.current),
    );
  });

  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  scheduleMicrotask(refreshBalance);

  return controller.stream;
});
