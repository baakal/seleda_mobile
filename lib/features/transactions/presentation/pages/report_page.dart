import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Chart package (syncfusion_flutter_charts) is added in pubspec; ensure you run flutter pub get.
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:seleda_finance/app/di.dart';
import 'package:seleda_finance/features/transactions/domain/entities/transaction.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/transaction_type.dart';
import 'package:seleda_finance/app/widgets/app_header.dart';
import 'package:seleda_finance/features/transactions/presentation/style.dart';

enum ReportRange { week, month, year }

class ReportState {
  const ReportState({
    required this.range,
    required this.transactions,
  });

    final ReportRange range;
    final List<Transaction> transactions;

    double get netBalance => transactions.fold(0, (p, t) => p + (t.type == TransactionType.income ? t.amount.cents : -t.amount.cents) / 100.0);

    List<_ChartPoint> get pointsByDay {
      final Map<DateTime, double> map = {};
      for (final t in transactions) {
        final dt = DateTime.fromMillisecondsSinceEpoch(t.dateEpochMs);
        final day = DateTime(dt.year, dt.month, dt.day);
        final delta = (t.type == TransactionType.income ? t.amount.cents : -t.amount.cents) / 100.0;
        map.update(day, (value) => value + delta, ifAbsent: () => delta);
      }
      final sortedKeys = map.keys.toList()..sort();
      return [for (final k in sortedKeys) _ChartPoint(k, map[k]!)]..sort((a, b) => a.x.compareTo(b.x));
    }

  ReportState copyWith({ReportRange? range, List<Transaction>? transactions}) =>
      ReportState(range: range ?? this.range, transactions: transactions ?? this.transactions);
}

class ReportNotifier extends StateNotifier<ReportState> {
  ReportNotifier(this._ref) : super(const ReportState(range: ReportRange.month, transactions: [])) {
    _listen();
  }

  final Ref _ref;
  void _listen() {
    final useCase = _ref.read(watchTransactionsUseCaseProvider);
    useCase().listen((result) {
      result.fold(
        (data) => _updateTransactions(data),
        (_) {},
      );
    });
  }

  void _updateTransactions(List<Transaction> all) {
    final now = DateTime.now();
    final filtered = all.where((t) {
      final dt = DateTime.fromMillisecondsSinceEpoch(t.dateEpochMs);
      switch (state.range) {
        case ReportRange.week:
          final start = now.subtract(const Duration(days: 7));
          return dt.isAfter(start);
        case ReportRange.month:
          return dt.year == now.year && dt.month == now.month;
        case ReportRange.year:
          return dt.year == now.year;
      }
    }).toList();
    state = state.copyWith(transactions: filtered);
  }

  void setRange(ReportRange range) {
    state = state.copyWith(range: range);
    _updateTransactions(state.transactions); // re-filter using existing list (will refresh on next stream event)
  }
}

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) => ReportNotifier(ref));

class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(reportProvider);
    final notifier = ref.read(reportProvider.notifier);
    final points = report.pointsByDay;

    return Scaffold(
      appBar: const AppHeader(showSearch: false),
      body: Padding(
        padding: TxStyles.screenPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Net Balance', style: TxStyles.sectionTitle(context)),
                const SizedBox(width: TxStyles.spaceSm),
                Text(report.netBalance.toStringAsFixed(2), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                DropdownButton<ReportRange>(
                  value: report.range,
                  onChanged: (value) => value == null ? null : notifier.setRange(value),
                  items: const [
                    DropdownMenuItem(value: ReportRange.week, child: Text('This Week')),
                    DropdownMenuItem(value: ReportRange.month, child: Text('This Month')),
                    DropdownMenuItem(value: ReportRange.year, child: Text('This Year')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: TxStyles.spaceXl),
            Expanded(
              child: points.isEmpty
                  ? const Center(child: Text('No data for selected range'))
                  : SfCartesianChart(
                      primaryXAxis: DateTimeAxis(),
                      series: <CartesianSeries<_ChartPoint, DateTime>>[
                        LineSeries<_ChartPoint, DateTime>(
                          dataSource: points,
                          xValueMapper: (_ChartPoint p, _) => p.x,
                          yValueMapper: (_ChartPoint p, _) => p.y,
                          markerSettings: const MarkerSettings(isVisible: true),
                        )
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartPoint {
  _ChartPoint(this.x, this.y);
  final DateTime x;
  final double y;
}
