import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/expense_provider.dart';
import '../theme.dart';
import '../widgets/common.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ExpenseProvider>();
    final cats = p.monthByCategory;
    final top = cats.entries.isEmpty
        ? null
        : (cats.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
            .first;

    final donut = FadeIn(
      child: AppCard(
        child: Column(children: [
          const Align(
              alignment: Alignment.centerLeft,
              child: SectionTitle('This month by category')),
          DonutChart(
            data: cats,
            size: 210,
            centerLabel: 'Total spent',
            centerValue: money(p.monthExpense),
          ),
          const SizedBox(height: 16),
          Legend(data: cats),
        ]),
      ),
    );

    final weekly = FadeIn(
      delayMs: 150,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Last 7 days'),
            WeeklyBars(values: p.last7Days),
          ],
        ),
      ),
    );

    final tip = FadeIn(
      delayMs: 300,
      child: AppCard(
        gradient: const LinearGradient(
            colors: [Color(0xFFFFF3C4), AppColors.mint]),
        child: Row(children: [
          const Icon(Icons.lightbulb, color: AppColors.mustard, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              top == null
                  ? 'Add some expenses to unlock insights.'
                  : 'Your biggest spend this month is ${top.key.label} '
                      '(${money(top.value)}). '
                      'Remaining budget: ${money(p.budget - p.monthExpense)}.',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
          ),
        ]),
      ),
    );

    return LayoutBuilder(builder: (context, c) {
      final twoCol = c.maxWidth >= 760;
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          if (twoCol)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: donut),
              const SizedBox(width: 16),
              Expanded(child: weekly),
            ])
          else ...[
            donut,
            const SizedBox(height: 16),
            weekly,
          ],
          const SizedBox(height: 16),
          tip,
        ],
      );
    });
  }
}
