import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seleda_finance/features/transactions/presentation/controllers/transaction_list_controller.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/transaction_type.dart';

class CategorySummaryPage extends ConsumerWidget {
  const CategorySummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionListControllerProvider);
    final data = state.status.value ?? [];
    final Map<String, _CategoryAgg> map = {};
    for (final t in data) {
      final key = t.category ?? 'Uncategorized';
      final entry = map.putIfAbsent(key, () => _CategoryAgg());
      if (t.type == TransactionType.income) {
        entry.income += t.amount.cents / 100.0;
      } else {
        entry.expense += t.amount.cents / 100.0;
      }
    }
    final rows = map.entries.toList()
      ..sort((a, b) => (b.value.net.abs()).compareTo(a.value.net.abs()));

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: state.status.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (_) => rows.isEmpty
            ? const Center(child: Text('No transactions'))
            : ListView.separated(
                itemCount: rows.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final e = rows[index];
                  final net = e.value.net;
                  final color = net >= 0 ? Colors.green : Colors.red;
                  return ListTile(
                    title: Text(e.key),
                    subtitle: Text('Income: ${e.value.income.toStringAsFixed(2)}  Expense: ${e.value.expense.toStringAsFixed(2)}'),
                    trailing: Text(net.toStringAsFixed(2), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                  );
                },
              ),
      ),
    );
  }
}

class _CategoryAgg {
  double income = 0;
  double expense = 0;
  double get net => income - expense;
}
