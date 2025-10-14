import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:seleda_finance/features/transactions/domain/value_objects/transaction_type.dart';
import 'package:seleda_finance/features/transactions/presentation/pages/add_transaction_page.dart';
import 'package:seleda_finance/features/transactions/presentation/pages/dashboard_page.dart';
import 'package:seleda_finance/features/transactions/presentation/pages/transactions_page.dart';
import 'package:seleda_finance/features/transactions/presentation/pages/report_page.dart';
import 'package:seleda_finance/features/transactions/presentation/pages/settings_page.dart';
import 'package:seleda_finance/app/widgets/app_bottom_navigation.dart';
import 'package:seleda_finance/app/widgets/expandable_fab.dart';
import 'package:seleda_finance/features/transactions/presentation/pages/splash_page.dart';
import 'package:seleda_finance/features/transactions/presentation/pages/account_page.dart';
import 'package:seleda_finance/features/transactions/presentation/pages/category_summary_page.dart';
import 'package:seleda_finance/features/transactions/presentation/pages/search_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          // Determine current index based on location
          final location = state.uri.toString();
          int index = 0;
          if (location.startsWith('/categories')) index = 1;
          else if (location.startsWith('/search')) index = 2;
          else if (location.startsWith('/reports')) index = 3;
          else if (location.startsWith('/settings')) index = 4;
          return Scaffold(
            body: child,
            floatingActionButton: const ExpandableFab(),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: AppBottomNavigation(currentIndex: index),
            extendBody: true,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          // Hidden route still accessible (not on nav) for full transaction list if needed
          GoRoute(
            path: '/transactions',
            name: 'transactions',
            builder: (context, state) => const TransactionsPage(),
          ),
          GoRoute(
            path: '/categories',
            name: 'categories',
            builder: (context, state) => const CategorySummaryPage(),
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchPage(),
          ),
          GoRoute(
            path: '/reports',
            name: 'reports',
            builder: (context, state) => const ReportPage(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/account',
            name: 'account',
            builder: (context, state) => const AccountPage(),
          ),
        ],
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
