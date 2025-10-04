import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seleda_finance/app/di.dart';
import 'package:seleda_finance/features/transactions/domain/entities/transaction.dart' as domain;
import 'package:seleda_finance/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/date_range.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/transaction_type.dart';
import 'package:seleda_finance/features/transactions/external/image/image_picker_adapter.dart';
import 'package:seleda_finance/features/transactions/external/voice/stt_adapter.dart';
import 'package:seleda_finance/features/transactions/presentation/pages/add_transaction_page.dart';
import 'package:seleda_finance/features/transactions/presentation/pages/dashboard_page.dart';
import 'package:seleda_finance/features/transactions/presentation/pages/transactions_page.dart';

class _FakeRepository implements TransactionRepository {
  _FakeRepository() : _controller = StreamController<List<domain.Transaction>>.broadcast() {
    _controller.onListen = _emit;
  }

  final _transactions = <domain.Transaction>[];
  final StreamController<List<domain.Transaction>> _controller;

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
  Future<void> update(domain.Transaction transaction) async {
    final index = _transactions.indexWhere((item) => item.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      _emit();
    }
  }

  @override
  Stream<List<domain.Transaction>> watchAll({DateRange? range, String? category}) {
    return _controller.stream;
  }
}

class _FakeImagePicker extends ImagePickerAdapter {}

class _FakeSpeechAdapter extends SpeechToTextAdapter {
  @override
  Future<String?> dictateOnce() async => null;
}

void main() {
  testWidgets('adding and deleting transactions updates UI', (tester) async {
    final repository = _FakeRepository();
    final container = ProviderContainer(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(repository),
        imagePickerAdapterProvider.overrideWithValue(_FakeImagePicker()),
        speechToTextAdapterProvider.overrideWithValue(_FakeSpeechAdapter()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: AddTransactionPage(defaultType: TransactionType.income),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, '50');
    await tester.enterText(find.widgetWithText(TextField, 'Category'), 'Freelance');
    await tester.enterText(find.widgetWithText(TextField, 'Note'), 'Side gig');
    await tester.tap(find.text('Save Transaction'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TransactionsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Freelance'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Freelance'), findsNothing);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: DashboardPage()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Balance'), findsOneWidget);
    expect(find.textContaining('0.00'), findsWidgets);
  });
}
