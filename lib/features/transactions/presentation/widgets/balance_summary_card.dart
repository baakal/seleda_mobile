import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seleda_finance/shared/formatters/money_formatter.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/transaction_type.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/money.dart';
import 'package:seleda_finance/features/transactions/presentation/controllers/balance_controller.dart';

/// Stylized balance summary matching provided design reference while preserving
/// existing app color scheme. Shows total balance and expandable income/expense.
class BalanceSummaryCard extends ConsumerStatefulWidget {
  const BalanceSummaryCard({super.key});

  @override
  ConsumerState<BalanceSummaryCard> createState() => _BalanceSummaryCardState();
}

class _BalanceSummaryCardState extends ConsumerState<BalanceSummaryCard> with SingleTickerProviderStateMixin {
  bool _expanded = true;
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
  late final Animation<double> _expand = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);

  @override
  void initState() {
    super.initState();
    _controller.value = 1; // start expanded
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final balanceAsync = ref.watch(balanceProvider);

    return balanceAsync.when(
      loading: () => const SizedBox(height: 160, child: Center(child: CircularProgressIndicator())),
      error: (err, _) => Container(
        padding: const EdgeInsets.all(20),
        decoration: _decoration(scheme),
        child: Text('Error: $err', style: TextStyle(color: scheme.onPrimary)),
      ),
      data: (money) {
        final amountStyle = Theme.of(context).textTheme.displaySmall?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: -1,
            );
        // For now we don't have segregated income/expense totals exposed in balance state.
        // Placeholder logic: positive money => income, negative => expense magnitudes.
  // Placeholder separation: if overall balance negative, treat absolute as expense; if positive, treat as income.
  final income = money.cents >= 0 ? money : Money.zero();
  final expense = money.cents < 0 ? money.abs() : Money.zero();

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          decoration: _decoration(scheme),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _toggle,
                    child: Row(
                      children: [
                        Text('Total Balance', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onPrimary)),
                        const SizedBox(width: 4),
                        AnimatedRotation(
                          turns: _expanded ? 0 : .5,
                          duration: const Duration(milliseconds: 250),
                          child: Icon(Icons.keyboard_arrow_up, color: scheme.onPrimary),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.more_horiz, color: scheme.onPrimary),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                formatMoney(money, type: money.cents >= 0 ? TransactionType.income : TransactionType.expense),
                style: amountStyle,
              ),
              SizeTransition(
                sizeFactor: _expand,
                axisAlignment: -1,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _miniMetric(
                          context,
                          label: 'Income',
                          icon: Icons.arrow_downward,
                          value: formatMoney(income, type: TransactionType.income),
                          scheme: scheme,
                        ),
                        const SizedBox(width: 32),
                        _miniMetric(
                          context,
                          label: 'Expenses',
                          icon: Icons.arrow_upward,
                          value: formatMoney(expense, type: TransactionType.expense),
                          scheme: scheme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  BoxDecoration _decoration(ColorScheme scheme) {
    return BoxDecoration(
      color: scheme.primary.withOpacity(.85),
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: scheme.primary.withOpacity(.35),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget _miniMetric(BuildContext context, {required String label, required IconData icon, required String value, required ColorScheme scheme}) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: scheme.onPrimary.withOpacity(.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 16, color: scheme.onPrimary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onPrimary)),
                Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onPrimary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
