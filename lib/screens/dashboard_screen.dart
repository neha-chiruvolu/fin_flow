import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/expense_provider.dart';
import '../theme.dart';
import '../widgets/common.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ExpenseProvider>();
    final recent = p.items.take(5).toList();
    final frac = p.budget <= 0 ? 0.0 : (p.monthExpense / p.budget);

    final balanceCard = FadeIn(
      child: AppCard(
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.blue, AppColors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Total balance',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: p.balance),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOut,
              builder: (_, v, __) => Text(money(v),
                  style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
            ),
            const SizedBox(height: 18),
            Wrap(spacing: 12, runSpacing: 12, children: [
              _pill(Icons.arrow_downward, 'Income', p.monthIncome,
                  AppColors.mint, AppColors.green),
              _pill(Icons.arrow_upward, 'Spent', p.monthExpense,
                  const Color(0xFFFFF3C4), AppColors.mustard),
            ]),
          ],
        ),
      ),
    );

    final budgetCard = FadeIn(
      delayMs: 100,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle('Monthly budget',
                trailing: Text(
                  '${(frac * 100).clamp(0, 999).round()}% used',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: frac > 1 ? Colors.redAccent : AppColors.green),
                )),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: frac.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: v,
                  minHeight: 14,
                  backgroundColor: AppColors.sky,
                  color: frac > 0.85 ? AppColors.mustard : AppColors.green,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text('${money(p.monthExpense)} of ${money(p.budget)}'),
            if (frac > 1)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('You are over budget this month.',
                    style: TextStyle(color: Colors.redAccent)),
              ),
          ],
        ),
      ),
    );

    final chartCard = FadeIn(
      delayMs: 200,
      child: AppCard(
        child: Column(children: [
          const Align(
              alignment: Alignment.centerLeft,
              child: SectionTitle('Spending by category')),
          DonutChart(
            data: p.monthByCategory,
            centerLabel: 'This month',
            centerValue: money(p.monthExpense),
          ),
          const SizedBox(height: 14),
          Legend(data: p.monthByCategory),
        ]),
      ),
    );

    final recentCard = FadeIn(
      delayMs: 300,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Recent activity'),
            if (recent.isEmpty) const Text('No transactions yet. Tap Add!'),
            for (final t in recent) TxTile(tx: t),
          ],
        ),
      ),
    );

    return LayoutBuilder(builder: (context, c) {
      final twoCol = c.maxWidth >= 760;
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 14, left: 4),
            child: Text(
              'Hello, ${p.userName.isEmpty ? 'there' : p.userName} 👋',
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink),
            ),
          ),
          if (twoCol)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: balanceCard),
              const SizedBox(width: 16),
              Expanded(child: budgetCard),
            ])
          else ...[
            balanceCard,
            const SizedBox(height: 16),
            budgetCard,
          ],
          const SizedBox(height: 16),
          if (twoCol)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: chartCard),
              const SizedBox(width: 16),
              Expanded(child: recentCard),
            ])
          else ...[
            chartCard,
            const SizedBox(height: 16),
            recentCard,
          ],
        ],
      );
    });
  }

  Widget _pill(IconData i, String label, double v, Color bg, Color fg) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
            color: bg.withOpacity(0.95),
            borderRadius: BorderRadius.circular(14)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(i, size: 18, color: fg),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.black54)),
            Text(money(v),
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: AppColors.ink)),
          ]),
        ]),
      );
}
