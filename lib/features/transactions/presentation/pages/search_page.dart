import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seleda_finance/features/transactions/presentation/controllers/transaction_list_controller.dart';
import 'package:seleda_finance/features/transactions/presentation/style.dart';

final searchQueryProvider = StateProvider<String>((_) => '');

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final state = ref.watch(transactionListControllerProvider);
    final all = state.status.value ?? [];
    final filtered = query.isEmpty
        ? all
        : all.where((t) {
            final q = query.toLowerCase();
            return (t.category ?? '').toLowerCase().contains(q) || (t.note ?? '').toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: TxStyles.screenPadding.copyWith(top: TxStyles.spaceLg, bottom: TxStyles.spaceSm),
            child: TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search category or note'),
              onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
            ),
          ),
          Expanded(
            child: state.status.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (_) => filtered.isEmpty
                  ? const Center(child: Text('No matching transactions'))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final t = filtered[i];
                        return ListTile(
                          title: Text(t.category ?? 'Uncategorized'),
                          subtitle: Text(t.note ?? ''),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
