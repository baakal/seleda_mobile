import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seleda_finance/app/di.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/transaction_type.dart';
import 'package:seleda_finance/features/transactions/presentation/controllers/transaction_list_controller.dart';
import 'package:seleda_finance/features/transactions/presentation/widgets/transaction_list_item.dart';
import 'package:seleda_finance/features/transactions/presentation/style.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionListControllerProvider);
    final transactions = state.filteredTransactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              TxStyles.spaceLg,
              TxStyles.spaceSm,
              TxStyles.spaceLg,
              TxStyles.spaceSm,
            ),
            child: Wrap(
              spacing: TxStyles.spaceSm,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: state.filter == null,
                  onSelected: (_) => ref.read(transactionListControllerProvider.notifier).setFilter(null),
                ),
                ChoiceChip(
                  label: const Text('Income'),
                  selected: state.filter == TransactionType.income,
                  onSelected: (_) => ref.read(transactionListControllerProvider.notifier).setFilter(TransactionType.income),
                ),
                ChoiceChip(
                  label: const Text('Expense'),
                  selected: state.filter == TransactionType.expense,
                  onSelected: (_) => ref.read(transactionListControllerProvider.notifier).setFilter(TransactionType.expense),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.status.when(
              data: (_) => transactions.isEmpty
                  ? const Center(child: Text('No transactions found.'))
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return TransactionListItem(
                          transaction: transaction,
                          onDelete: () async {
                            final useCase = ref.read(deleteTransactionUseCaseProvider);
                            final result = await useCase(transaction.id);
                            result.fold(
                              (_) => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Transaction deleted')),
                              ),
                              (error) => ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error deleting: ${error.message}')),
                              ),
                            );
                          },
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
