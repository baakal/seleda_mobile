import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:seleda_finance/app/di.dart';
import 'package:seleda_finance/shared/formatters/money_formatter.dart';
import 'package:seleda_finance/features/transactions/domain/entities/transaction.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/transaction_type.dart';
import 'package:seleda_finance/features/transactions/external/voice/stt_adapter.dart';
import 'package:seleda_finance/features/transactions/presentation/controllers/balance_controller.dart';
import 'package:seleda_finance/features/transactions/presentation/controllers/transaction_list_controller.dart';
import 'package:seleda_finance/features/transactions/presentation/widgets/transaction_list_item.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(balanceProvider);
    final transactionState = ref.watch(transactionListControllerProvider);
    final transactions = transactionState.status.value ?? <Transaction>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleda Finance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () => context.push('/transactions'),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'income',
            onPressed: () => context.push('/add?type=income'),
            icon: const Icon(Icons.add),
            label: const Text('+ Income'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'expense',
            onPressed: () => context.push('/add?type=expense'),
            icon: const Icon(Icons.remove),
            label: const Text('+ Expense'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'voice',
            onPressed: () async {
              final adapter = ref.read(speechToTextAdapterProvider);
              final transcript = await adapter.dictateOnce();
              if (transcript == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Voice input unavailable')),
                  );
                }
                return;
              }
              if (context.mounted) {
                context.push('/add', extra: transcript);
              }
            },
            icon: const Icon(Icons.mic),
            label: const Text('Mic Add'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(transactionListControllerProvider);
          ref.invalidate(balanceProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            balanceAsync.when(
              data: (money) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Balance', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        formatMoney(money, type: money.cents >= 0 ? TransactionType.income : TransactionType.expense),
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading balance: $error'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Recent Transactions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (transactionState.status.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (transactions.isEmpty)
              const Text('No transactions yet.')
            else
              ...transactions.take(5).map(
                (transaction) => TransactionListItem(transaction: transaction),
              ),
          ],
        ),
      ),
    );
  }
}
