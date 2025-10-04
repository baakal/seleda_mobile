import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:seleda_finance/features/transactions/domain/value_objects/transaction_type.dart';
import 'package:seleda_finance/features/transactions/presentation/pages/add_transaction_page.dart';
import 'package:seleda_finance/features/transactions/presentation/pages/dashboard_page.dart';
import 'package:seleda_finance/features/transactions/presentation/pages/transactions_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/transactions',
        name: 'transactions',
        builder: (context, state) => const TransactionsPage(),
      ),
      GoRoute(
        path: '/add',
        name: 'add',
        builder: (context, state) {
          final typeQuery = state.uri.queryParameters['type'];
          final type = typeQuery != null ? TransactionType.fromName(typeQuery) : TransactionType.expense;
          final voicePrefill = state.extra is String ? state.extra as String : null;
          return AddTransactionPage(defaultType: type, voicePrefill: voicePrefill);
        },
      ),
    ],
  );
});
