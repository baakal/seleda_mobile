import 'package:flutter/material.dart';

import 'package:seleda_finance/shared/formatters/money_formatter.dart';
import 'package:seleda_finance/features/transactions/domain/entities/transaction.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/transaction_type.dart';

class TransactionListItem extends StatelessWidget {
  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onDelete,
  });

  final Transaction transaction;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isIncome = transaction.type == TransactionType.income;
    final amountText = formatMoney(transaction.amount, type: transaction.type);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome ? colorScheme.secondaryContainer : colorScheme.errorContainer,
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? colorScheme.onSecondaryContainer : colorScheme.onErrorContainer,
          ),
        ),
        title: Text(transaction.category ?? (isIncome ? 'Income' : 'Expense')),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.note != null && transaction.note!.isNotEmpty)
              Text(transaction.note!),
            Text(
              DateTime.fromMillisecondsSinceEpoch(transaction.dateEpochMs).toIso8601String().split('T').first,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (transaction.attachments.isNotEmpty)
              Text('${transaction.attachments.length} attachment(s)', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amountText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isIncome ? colorScheme.primary : colorScheme.error,
                  ),
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
