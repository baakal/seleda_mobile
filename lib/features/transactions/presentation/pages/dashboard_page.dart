import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Removed go_router and DI imports; navigation now handled by global FAB.
import 'package:seleda_finance/features/transactions/domain/entities/transaction.dart';
import 'package:seleda_finance/features/transactions/presentation/controllers/transaction_list_controller.dart';
import 'package:seleda_finance/features/transactions/presentation/widgets/transaction_list_item.dart';
import 'package:seleda_finance/app/widgets/app_header.dart';
import 'package:seleda_finance/app/widgets/expandable_fab.dart';
import 'package:seleda_finance/features/transactions/presentation/widgets/balance_summary_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionState = ref.watch(transactionListControllerProvider);
    final transactions = transactionState.status.value ?? <Transaction>[];

    return Scaffold(
      appBar: const AppHeader(),
      // FABs moved to global shell (ExpandableFab). This page now only provides body.
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(transactionListControllerProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16,16,16,kExpandableFabBottomPadding),
          children: [
            const BalanceSummaryCard(),
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
